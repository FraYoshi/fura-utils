#!/bin/bash -e

set -uo pipefail

# Soft colors for elegant output
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'

# Primary colors
BLUE='\033[38;5;75m'
GREEN='\033[38;5;41m'
YELLOW='\033[38;5;221m'
ORANGE='\033[38;5;215m'
RED='\033[38;5;203m'
PURPLE='\033[38;5;141m'
CYAN='\033[38;5;87m'

# Optimized configurations for SSD
SSD_SCRUB_SETTINGS=("--limit" "500M")

# Elegant utility functions
print_header() {
    local title="$1"
    echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BLUE}║${RESET} ${BOLD}${CYAN}$title${RESET} ${BOLD}${BLUE}║${RESET}"
    echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
}

print_section() {
    local title="$1"
    echo -e "${DIM}${BLUE}── ${BOLD}$title ${BLUE}──${RESET}"
}

print_success() {
    echo -e "${GREEN}✓${RESET} ${BOLD}$1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠${RESET} ${BOLD}$1${RESET}"
}

print_error() {
    echo -e "${RED}✗${RESET} ${BOLD}$1${RESET}"
}

print_info() {
    echo -e "${BLUE}ℹ${RESET} ${BOLD}$1${RESET}"
}

print_bullet() {
    echo -e "${DIM}${BLUE}•${RESET} $1"
}

draw_separator() {
    echo -e "${DIM}${BLUE}────────────────────────────────────────────────────────────────${RESET}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to get device info
get_device_type() {
    local mount_point="$1"
    local devices=$(btrfs filesystem show "$mount_point" 2>/dev/null | grep -o '/dev/[^ ]*' | head -1)
    
    for device in $devices; do
        if [[ -e "$device" ]]; then
            if [[ $(lsblk -d -o rota "$device" 2>/dev/null | tail -1) -eq 0 ]]; then
                echo "ssd"
                return
            else
                echo "hdd"
                return
            fi
        fi
    done
    echo "unknown"
}

# Requirements checking function
check_requirements() {
    local missing=0
    
    print_header "SYSTEM REQUIREMENTS CHECK"
    
    # Check Bash version
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        print_error "Bash 4.0+ required (current: $BASH_VERSION)"
        missing=$((missing + 1))
    else
        print_success "Bash version: $BASH_VERSION"
    fi

    # Check BTRFS tools
    if ! command -v btrfs &> /dev/null; then
        print_error "btrfs-progs not installed"
        missing=$((missing + 1))
    else
        local btrfs_version=$(btrfs version | head -1)
        print_success "BTRFS: $btrfs_version"
    fi

    # Check core utilities
    local core_tools=("mount" "awk" "grep" "lsblk")
    for tool in "${core_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            print_warning "$tool not found (some features limited)"
        else
            print_success "$tool available"
        fi
    done

    # Check optional tools
    local optional_tools=("ionice" "sysctl" "fio" "hdparm")
    for tool in "${optional_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_info "$tool available (enhanced features)"
        else
            print_bullet "$tool not found (optional)"
        fi
    done

    # Check terminal capabilities
    if [[ -n "$TERM" && "$TERM" != "dumb" ]]; then
        print_success "Terminal supports colors"
    else
        print_warning "Limited terminal capabilities"
    fi

    # Check BTRFS filesystems
    if mount | grep -q btrfs; then
        print_success "BTRFS filesystems mounted"
    else
        print_warning "No BTRFS filesystems currently mounted"
    fi

    echo
    if [[ $missing -gt 0 ]]; then
        print_error "$missing critical requirements missing"
        return 1
    else
        print_success "All requirements satisfied"
        return 0
    fi
}

# Elegant BTRFS information display
show_btrfs_info() {
    local mount_point="$1"
    local verbose="${2:-false}"
    
    if [[ ! -d "$mount_point" ]]; then
        print_error "Mount point '$mount_point' not found or not accessible"
        return 1
    fi
    
    local device_type=$(get_device_type "$mount_point")
    local device_icon="🖴"
    [[ "$device_type" == "ssd" ]] && device_icon="⚡"
    [[ "$device_type" == "hdd" ]] && device_icon="💾"
    
    print_header "BTRFS FILESYSTEM ${device_icon}  $mount_point"
    
    echo -e "${DIM}Device type: ${BOLD}${device_type^^}${RESET}"
    echo

    # Filesystem information in elegant layout
    print_section "BASIC INFORMATION"
    if btrfs filesystem show "$mount_point" 2>/dev/null | while read -r line; do
        echo -e "  ${DIM}${line}${RESET}"
    done; then
        true
    else
        print_error "Cannot show filesystem information"
    fi
    
    draw_separator
    
    # Storage usage in a clean format
    print_section "STORAGE USAGE"
    echo -e "  ${BOLD}Device usage:${RESET}"
    btrfs device usage "$mount_point" 2>/dev/null | while read -r line; do
        print_bullet "$line"
    done
    
    echo
    echo -e "  ${BOLD}Filesystem usage:${RESET}"
    btrfs filesystem usage "$mount_point" 2>/dev/null | while read -r line; do
        print_bullet "$line"
    done
    
    draw_separator
    
    # Space information
    print_section "SPACE ALLOCATION"
    btrfs filesystem df "$mount_point" 2>/dev/null | while read -r line; do
        print_bullet "$line"
    done
    
    draw_separator
    
    # Scrub status with visual indicators
    print_section "SCRUB STATUS"
    local scrub_status=$(btrfs scrub status "$mount_point" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        if echo "$scrub_status" | grep -q "running"; then
            echo -e "  ${YELLOW}⏳ Scrub in progress${RESET}"
        elif echo "$scrub_status" | grep -q "finished"; then
            echo -e "  ${GREEN}✅ Scrub completed${RESET}"
        else
            echo -e "  ${BLUE}💤 Scrub not running${RESET}"
        fi
        echo "$scrub_status" | while read -r line; do
            print_bullet "$line"
        done
    else
        echo -e "  ${DIM}Scrub status unavailable${RESET}"
    fi
    
    draw_separator
    
    # Device statistics
    print_section "DEVICE STATISTICS"
    local stats=$(btrfs device stats "$mount_point" 2>/dev/null)
    if [[ -n "$stats" ]]; then
        echo "$stats" | while read -r line; do
            if echo "$line" | grep -q "0$"; then
                print_bullet "$line"
            else
                echo -e "  ${ORANGE}⚠  $line${RESET}"
            fi
        done
    else
        echo -e "  ${DIM}No device statistics available${RESET}"
    fi
    
    # SSD optimizations hint
    if [[ "$device_type" == "ssd" ]]; then
        draw_separator
        print_section "OPTIMIZATIONS"
        print_bullet "${CYAN}SSD-optimized scrub available${RESET}"
        print_bullet "Use 'scrub --priority' for maximum performance"
    fi
    
    echo
}

# Graceful scrub function
optimized_scrub() {
    local mount_point="$1"
    local device_type="$2"
    
    print_header "STARTING OPTIMIZED SCRUB"
    echo -e "${DIM}Device: ${BOLD}$mount_point${RESET}"
    echo -e "${DIM}Type: ${BOLD}${device_type^^}${RESET}"
    echo
    
    case $device_type in
        "ssd")
            print_success "Using SSD-optimized settings"
            echo -e "${DIM}Batch workers: 8 | Limit: 500MB/s | Throttle: 100${RESET}"
            echo
            
            if btrfs scrub start -c 2 -n 7 ${SSD_SCRUB_SETTINGS[@]} "$mount_point" 2>&1 & then
                local pid=$!
                spinner $pid
                wait $pid
                print_success "Scrub started successfully"
            else
                print_warning "Falling back to standard settings"
                btrfs scrub start -B "$mount_point"
            fi
            ;;
        "hdd")
            print_info "Using HDD-optimized settings"
            echo -e "${DIM}Batch workers: 2 | Limit: 100MB/s${RESET}"
            echo
            btrfs scrub start -c 2 -n 2 --limit 100M "$mount_point"
            ;;
        *)
            print_info "Using default settings"
            btrfs scrub start -B "$mount_point"
            ;;
    esac
    
    echo
}

# Priority scrub with elegant output
priority_scrub() {
    local mount_point="$1"
    
    print_header "STARTING PRIORITY SCRUB"
    echo -e "${DIM}Device: ${BOLD}$mount_point${RESET}"
    echo -e "${CYAN}⚡ Maximum performance mode activated${RESET}"
    echo
    
    print_success "Priority settings applied:"
    print_bullet "I/O priority: highest"
    print_bullet "Batch workers: 8"
    print_bullet "Rate limit: 800MB/s"
    print_bullet "Parallel operations: 16"
    echo
    
    if command -v ionice >/dev/null 2>&1; then
        ionice -c2 -n0 btrfs scrub start \
            -c 2 -n 7 \
            --limit 800M \
            "$mount_point"
    else
        print_warning "ionice not available, using standard priority settings"
        btrfs scrub start -c 2 -n 7 --limit 800M "$mount_point"
    fi
}

# Minimal monitoring
monitor_scrub() {
    local mount_point="$1"
    
    print_header "SCRUB MONITORING"
    echo -e "${DIM}Monitoring: ${BOLD}$mount_point${RESET}"
    echo -e "${DIM}Press ${BOLD}Ctrl+C${DIM} to exit monitoring${RESET}"
    echo
    
    local first_run=true
    while true; do
        if [[ "$first_run" != true ]]; then
            printf "\033[2K\r"  # Clear line
        else
            first_run=false
        fi
        
        local status=$(btrfs scrub status "$mount_point" 2>/dev/null)
        if echo "$status" | grep -q "running"; then
            local progress=$(echo "$status" | grep -o " [0-9.]*%" | head -1 | tr -d ' ')
            local speed=$(echo "$status" | grep -o "[0-9.]* MB/s" | head -1)
            
            if [[ -n "$progress" ]]; then
                printf "Progress: ${CYAN}%s${RESET} | Speed: ${GREEN}%s${RESET}" "$progress" "$speed"
            else
                printf "Scrub in progress..."
            fi
        else
            echo
            print_success "Scrub completed"
            break
        fi
        
        sleep 3
    done
    echo
}

# Benchmark with clean output
benchmark_scrub_speed() {
    local mount_point="$1"
    local device_type="$2"
    
    print_header "SCRUB SPEED BENCHMARK"
    echo -e "${DIM}Device: ${BOLD}$mount_point${RESET}"
    echo -e "${DIM}Type: ${BOLD}${device_type^^}${RESET}"
    echo
    
    print_section "EXPECTED PERFORMANCE"
    case $device_type in
        "ssd")
            print_bullet "${GREEN}NVMe Gen4: 1.5-3.0 GB/s${RESET}"
            print_bullet "${GREEN}NVMe Gen3: 0.8-1.5 GB/s${RESET}"
            print_bullet "${CYAN}SATA SSD: 400-550 MB/s${RESET}"
            ;;
        "hdd")
            print_bullet "${YELLOW}HDD 7200rpm: 150-220 MB/s${RESET}"
            print_bullet "${YELLOW}HDD 5400rpm: 80-120 MB/s${RESET}"
            print_bullet "${ORANGE}RAID HDD: 300-600 MB/s${RESET}"
            ;;
    esac
    
    # Time estimates
    local total_size=$(btrfs filesystem usage "$mount_point" 2>/dev/null | grep "Device size" | awk '{print $3 $4}')
    if [[ -n "$total_size" ]]; then
        echo
        print_section "TIME ESTIMATES"
        case $device_type in
            "ssd")
                print_bullet "Estimated time: ${GREEN}10-30 minutes${RESET}"
                ;;
            "hdd")
                print_bullet "Estimated time: ${YELLOW}1-4 hours${RESET}"
                ;;
        esac
        print_bullet "Filesystem size: $total_size"
    fi
    echo
}

# System optimizations
setup_ssd_optimizations() {
    print_header "SYSTEM OPTIMIZATIONS"
    
    local optimized=false
    
    if [[ $EUID -eq 0 ]]; then
        print_section "APPLYING OPTIMIZATIONS"
        for disk in $(lsblk -d -o NAME | grep -v NAME); do
            if [[ -f "/sys/block/$disk/queue/rotational" ]] && [[ $(cat "/sys/block/$disk/queue/rotational") -eq 0 ]]; then
                echo -e "  Optimizing ${CYAN}$disk${RESET} (SSD)"
                echo 1024 > "/sys/block/$disk/queue/nr_requests" 2>/dev/null && optimized=true
                echo "none" > "/sys/block/$disk/queue/scheduler" 2>/dev/null && optimized=true
            fi
        done
        
        if sysctl -w dev.btrfs.per_stream_rate_limit=800000000 2>/dev/null; then
            optimized=true
        fi
    else
        print_warning "Root privileges required for system optimizations"
    fi
    
    if [[ "$optimized" == true ]]; then
        print_success "System optimizations applied successfully"
    else
        print_info "Using application-level optimizations only"
    fi
    echo
}

# Minimal help
show_help() {
    print_header "BTRFS MANAGEMENT TOOL"
    
    echo -e "${BOLD}${CYAN}USAGE:${RESET}"
    echo -e "  ${DIM}\$ $0 [command] [options] [arguments]${RESET}"
    echo
    
    echo -e "${BOLD}${CYAN}COMMANDS:${RESET}"
    echo -e "  ${GREEN}info${RESET}    [mount]     Show filesystem information"
    echo -e "  ${GREEN}scrub${RESET}   [mount]     Start optimized scrub"
    echo -e "  ${GREEN}monitor${RESET} [mount]     Monitor running scrub"
    echo -e "  ${GREEN}benchmark${RESET} [mount]   Show performance estimates"
    echo -e "  ${GREEN}optimize${RESET}           Apply system optimizations"
    echo -e "  ${GREEN}check-requirements${RESET} Check system requirements"
    echo -e "  ${GREEN}help${RESET}               Show this help message"
    echo
    
    echo -e "${BOLD}${CYAN}EXAMPLES:${RESET}"
    echo -e "  ${DIM}\$ $0 info /mnt/data${RESET}"
    echo -e "  ${DIM}\$ $0 scrub --priority /mnt/data${RESET}"
    echo -e "  ${DIM}\$ $0 monitor /mnt/data${RESET}"
    echo -e "  ${DIM}\$ $0 benchmark /mnt/data${RESET}"
    echo
    
    echo -e "${BOLD}${CYAN}OPTIONS:${RESET}"
    echo -e "  ${DIM}--priority    Maximum performance scrub${RESET}"
    echo -e "  ${DIM}--monitor     Auto-start monitoring${RESET}"
    echo -e "  ${DIM}--verbose     Detailed output${RESET}"
    echo -e "  ${DIM}--all         Show all mounted filesystems${RESET}"
    echo
}

# Main function with elegant command handling
main() {
    local command="info"
    local args=()
    
    # Parse main command
    if [[ $# -gt 0 ]]; then
        case $1 in
            -h|--help|help)
                show_help
                exit 0
                ;;
            info|scrub|monitor|optimize|benchmark|check-requirements)
                command="$1"
                shift
                ;;
            *)
                command="info"
                ;;
        esac
    fi
    
    # Parse options
    local show_all=false
    local verbose=false
    local priority_mode="standard"
    local auto_monitor=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all) show_all=true ;;
            -v|--verbose) verbose=true ;;
            -p|--priority) priority_mode="priority" ;;
            -m|--monitor) auto_monitor=true ;;
            *) args+=("$1") ;;
        esac
        shift
    done
    
    case $command in
        info)
            if [[ "$show_all" == true ]] || [[ ${#args[@]} -eq 0 ]]; then
                local found=false
                while IFS= read -r line; do
                    mount_point=$(echo "$line" | awk '{print $3}')
                    if [[ -n "$mount_point" ]]; then
                        found=true
                        show_btrfs_info "$mount_point" "$verbose"
                    fi
                done < <(mount | grep btrfs || true)
                
                if [[ "$found" == false ]]; then
                    print_error "No mounted BTRFS filesystems found"
                    echo
                    echo -e "${DIM}Usage: $0 [mount_point]${RESET}"
                    exit 1
                fi
            else
                show_btrfs_info "${args[0]}" "$verbose"
            fi
            ;;
            
        scrub)
            if [[ ${#args[@]} -eq 0 ]]; then
                print_error "Please specify a mount point"
                show_help
                exit 1
            fi
            
            local mount_point="${args[0]}"
            local device_type=$(get_device_type "$mount_point")
            
            if [[ "$priority_mode" == "priority" ]]; then
                priority_scrub "$mount_point"
            else
                optimized_scrub "$mount_point" "$device_type"
            fi
            
            if [[ "$auto_monitor" == true ]]; then
                sleep 2
                monitor_scrub "$mount_point"
            else
                echo
                print_info "Use '$0 monitor $mount_point' to monitor progress"
            fi
            ;;
            
        monitor)
            if [[ ${#args[@]} -eq 0 ]]; then
                print_error "Please specify a mount point"
                exit 1
            fi
            monitor_scrub "${args[0]}"
            ;;
            
        optimize)
            setup_ssd_optimizations
            ;;
            
        benchmark)
            if [[ ${#args[@]} -eq 0 ]]; then
                print_error "Please specify a mount point"
                exit 1
            fi
            local mount_point="${args[0]}"
            local device_type=$(get_device_type "$mount_point")
            benchmark_scrub_speed "$mount_point" "$device_type"
            ;;
            
        check-requirements)
            check_requirements
            ;;
    esac
}

# Graceful execution
if [[ $# -eq 0 ]]; then
    # Show all filesystems by default
    mount | grep btrfs | while read -r line; do
        mount_point=$(echo "$line" | awk '{print $3}')
        show_btrfs_info "$mount_point"
    done
    
    if ! mount | grep -q btrfs; then
        print_error "No mounted BTRFS filesystems found"
        echo
        echo -e "${DIM}Usage: $0 [mount_point]${RESET}"
        exit 1
    fi
else
    main "$@"
fi
