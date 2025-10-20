#!/bin/bash -e

set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Optimized configurations for SSD
SSD_SCRUB_SETTINGS=(
    "--batch-workers" "8"
    "--limit" "500"
    "--throttle" "100"
)

# Utility functions
draw_separator() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '─'
}

log_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

log_info() {
    echo -e "${BLUE}Info: $1${NC}"
}

log_success() {
    echo -e "${GREEN}Success: $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
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

# Complete BTRFS information (improved version)
show_btrfs_info() {
    local mount_point="$1"
    local verbose="${2:-false}"
    
    if [[ ! -d "$mount_point" ]]; then
        log_error "Mount point '$mount_point' not found or not accessible"
        return 1
    fi
    
    local device_type=$(get_device_type "$mount_point")
    
    echo -e "\n${GREEN}=== BTRFS Filesystem: $mount_point (${device_type^^}) ===${NC}"
    
    # Filesystem show with error control
    if ! btrfs filesystem show "$mount_point"; then
        log_error "Cannot show filesystem info for $mount_point"
        return 1
    fi
    
    draw_separator
    echo -e "${YELLOW}Device Stats:${NC}"
    btrfs device stats "$mount_point" 2>/dev/null || echo "N/A"
    
    draw_separator
    echo -e "${YELLOW}Filesystem DF:${NC}"
    btrfs filesystem df "$mount_point"
    
    draw_separator
    echo -e "${YELLOW}Device Usage:${NC}"
    btrfs device usage "$mount_point"
    
    draw_separator
    echo -e "${YELLOW}Filesystem Usage:${NC}"
    btrfs filesystem usage "$mount_point"
    
    draw_separator
    echo -e "${YELLOW}Scrub Status:${NC}"
    local scrub_status=$(btrfs scrub status "$mount_point" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        echo "$scrub_status"
    else
        echo "Scrub not running or not available"
    fi
    
    # Additional information for SSD
    if [[ "$device_type" == "ssd" ]]; then
        draw_separator
        echo -e "${CYAN}SSD Optimizations Available:${NC}"
        echo "• Optimized scrub with batch-workers=8, limit=500MB/s"
        echo "• I/O prioritization with ionice"
        echo "• Increased queue depth"
    fi
    
    # Verbose information
    if [[ "$verbose" == "true" ]]; then
        draw_separator
        echo -e "${PURPLE}Detailed Information:${NC}"
        btrfs filesystem du -s "$mount_point" 2>/dev/null || true
        btrfs subvolume list "$mount_point" 2>/dev/null | head -10
    fi
    
    echo
}

# Optimized scrub
optimized_scrub() {
    local mount_point="$1"
    local device_type="$2"
    
    echo -e "${GREEN}Starting optimized scrub for $device_type on $mount_point${NC}"
    
    case $device_type in
        "ssd")
            log_info "SSD configuration: batch-workers=8, limit=500MB/s"
            if btrfs scrub start -B -c 2 -n 8 -d 8 ${SSD_SCRUB_SETTINGS[@]} "$mount_point"; then
                log_success "Scrub started successfully with SSD settings"
            else
                log_warning "Fallback to standard settings"
                btrfs scrub start -B "$mount_point"
            fi
            ;;
        "hdd")
            log_info "HDD configuration: batch-workers=2, limit=100MB/s"
            btrfs scrub start -B -c 2 -n 2 -d 2 --limit 100 "$mount_point"
            ;;
        *)
            log_info "Default configuration"
            btrfs scrub start -B "$mount_point"
            ;;
    esac
}

# Maximum priority scrub
priority_scrub() {
    local mount_point="$1"
    
    echo -e "${PURPLE}Starting high priority scrub for SSD${NC}"
    
    # I/O priority setting with ionice
    if command -v ionice >/dev/null 2>&1; then
        ionice -c2 -n0 btrfs scrub start -B \
            -c 2 \
            -n 8 \
            -d 8 \
            --batch-workers 8 \
            --limit 800 \
            --throttle 50 \
            "$mount_point"
    else
        log_warning "ionice not available, using standard SSD settings"
        btrfs scrub start -B -c 2 -n 8 -d 8 --batch-workers 8 --limit 800 "$mount_point"
    fi
}

# Advanced scrub monitoring
monitor_scrub() {
    local mount_point="$1"
    
    echo -e "${BLUE}Real-time scrub monitoring:${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop monitoring${NC}"
    
    local first_run=true
    while true; do
        if [[ "$first_run" != true ]]; then
            clear
        fi
        first_run=false
        
        echo -e "${GREEN}=== Scrub Status $mount_point ===${NC}"
        btrfs scrub status "$mount_point"
        
        # Check if scrub is completed
        if ! btrfs scrub status "$mount_point" 2>/dev/null | grep -q "running"; then
            echo -e "${GREEN}Scrub completed!${NC}"
            break
        fi
        
        sleep 5
    done
}

# Scrub speed benchmark
benchmark_scrub_speed() {
    local mount_point="$1"
    local device_type="$2"
    
    echo -e "${CYAN}=== SCRUB SPEED BENCHMARK ===${NC}"
    
    # Estimated scrub speed based on device
    case $device_type in
        "ssd")
            echo -e "${GREEN}Expected SSD scrub speed:${NC}"
            echo "• NVMe Gen4: 1.5-3 GB/s"
            echo "• NVMe Gen3: 0.8-1.5 GB/s" 
            echo "• SATA SSD: 400-550 MB/s"
            ;;
        "hdd")
            echo -e "${YELLOW}Expected HDD scrub speed:${NC}"
            echo "• HDD 7200rpm: 150-220 MB/s"
            echo "• HDD 5400rpm: 80-120 MB/s"
            echo "• RAID HDD: 300-600 MB/s"
            ;;
    esac
    
    # Total size and time estimate
    local total_size=$(btrfs filesystem usage "$mount_point" 2>/dev/null | grep "Device size" | awk '{print $3 $4}')
    if [[ -n "$total_size" ]]; then
        echo -e "\n${YELLOW}Filesystem size: $total_size${NC}"
        
        # Approximate time estimate
        case $device_type in
            "ssd")
                echo "Estimated scrub time: 10-30 minutes"
                ;;
            "hdd")
                echo "Estimated scrub time: 1-4 hours"
                ;;
        esac
    fi
}

# System configurations for SSD
setup_ssd_optimizations() {
    echo -e "${CYAN}Applying SSD optimizations for BTRFS...${NC}"
    
    local optimized=false
    
    # Increase queue depth for SSD (requires root)
    if [[ $EUID -eq 0 ]]; then
        for disk in $(lsblk -d -o NAME | grep -v NAME); do
            if [[ -f "/sys/block/$disk/queue/rotational" ]] && [[ $(cat "/sys/block/$disk/queue/rotational") -eq 0 ]]; then
                echo "Optimizing $disk (SSD)"
                echo 1024 > "/sys/block/$disk/queue/nr_requests" 2>/dev/null && optimized=true
                echo "none" > "/sys/block/$disk/queue/scheduler" 2>/dev/null && optimized=true
            fi
        done
        
        # Increase BTRFS limits
        if sysctl -w dev.btrfs.per_stream_rate_limit=800000000 2>/dev/null; then
            optimized=true
        fi
    else
        log_warning "Root privileges required for system optimizations"
    fi
    
    if [[ "$optimized" == true ]]; then
        log_success "SSD optimizations applied successfully"
    else
        log_info "Using application-level optimizations"
    fi
}

# Complete help
show_help() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS] [ARGUMENTS]

BTRFS Management Tool - Information and Optimized Scrub

COMMANDS:
    info [MOUNT_POINT]          Show BTRFS information (default)
    scrub [OPTIONS] MOUNT_POINT  Start optimized scrub
    monitor MOUNT_POINT         Monitor running scrub
    optimize                    Apply SSD optimizations
    benchmark MOUNT_POINT       Benchmark scrub speed

INFO OPTIONS:
    -a, --all                   Show all mounted BTRFS filesystems
    -v, --verbose               Show detailed information

SCRUB OPTIONS:
    -p, --priority              Priority mode (maximum performance)
    -s, --standard              Standard optimized scrub (default)
    -m, --monitor               Automatically start monitoring

EXAMPLES:
    $0                              # Info all filesystems
    $0 info /mnt/btrfs             # Info specific mount
    $0 info --all -v               # All filesystems with details
    $0 scrub /mnt/btrfs            # Auto-optimized scrub
    $0 scrub -p /mnt/btrfs         # Priority scrub
    $0 scrub -m /mnt/btrfs         # Scrub with monitoring
    $0 monitor /mnt/btrfs          # Monitoring only
    $0 optimize                    # Apply SSD optimizations
    $0 benchmark /mnt/btrfs        # Speed benchmark

SSD OPTIMIZATIONS:
    • batch-workers: 8 (instead of 2)
    • limit: 500-800MB/s (instead of 100MB/s)
    • throttle: 100 (minimum for SSD)
    • I/O scheduling: ionice class 2
    • Queue depth: 1024
    • Parallel workers: 8 normal + 8 dedup

TYPICAL SCRUB SPEEDS:
    • NVMe SSD: 1.0-2.5 GB/s (3-7 minutes per 1TB)
    • SATA SSD: 250-450 MB/s (35-60 minutes per 1TB) 
    • HDD: 80-180 MB/s (1.5-3 hours per 1TB)

EOF
}

# Main function
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
            info|scrub|monitor|optimize|benchmark)
                command="$1"
                shift
                ;;
            *)
                # Default to info if not specified
                command="info"
                ;;
        esac
    fi
    
    # Parse remaining options
    local show_all=false
    local verbose=false
    local priority_mode="standard"
    local auto_monitor=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                show_all=true
                ;;
            -v|--verbose)
                verbose=true
                ;;
            -p|--priority)
                priority_mode="priority"
                ;;
            -s|--standard)
                priority_mode="standard"
                ;;
            -m|--monitor)
                auto_monitor=true
                ;;
            *)
                args+=("$1")
                ;;
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
                    log_error "No mounted BTRFS filesystem found"
                    echo "Usage: $0 [mount_point]"
                    exit 1
                fi
            else
                show_btrfs_info "${args[0]}" "$verbose"
            fi
            ;;
            
        scrub)
            if [[ ${#args[@]} -eq 0 ]]; then
                log_error "Specify a mount point for scrub"
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
                echo -e "${YELLOW}Use '$0 monitor $mount_point' to monitor the scrub${NC}"
            fi
            ;;
            
        monitor)
            if [[ ${#args[@]} -eq 0 ]]; then
                log_error "Specify a mount point for monitoring"
                exit 1
            fi
            monitor_scrub "${args[0]}"
            ;;
            
        optimize)
            setup_ssd_optimizations
            ;;
            
        benchmark)
            if [[ ${#args[@]} -eq 0 ]]; then
                log_error "Specify a mount point for benchmark"
                exit 1
            fi
            local mount_point="${args[0]}"
            local device_type=$(get_device_type "$mount_point")
            show_btrfs_info "$mount_point"
            benchmark_scrub_speed "$mount_point" "$device_type"
            ;;
    esac
}

# Execute the program
if [[ $# -eq 0 ]]; then
    # Original behavior: show all filesystems
    mount | grep btrfs | while read -r line; do
        mount_point=$(echo "$line" | awk '{print $3}')
        show_btrfs_info "$mount_point"
    done
    
    # If no BTRFS filesystems found
    if ! mount | grep -q btrfs; then
        echo "Error: No mounted BTRFS filesystem found"
        echo "Usage: $0 [mount_point]"
        exit 1
    fi
else
    main "$@"
fi
