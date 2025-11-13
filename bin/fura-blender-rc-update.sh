#!/bin/bash

source "$HOME"/.config/furayoshi/config.sh

################################################################################
# Blender Latest Release Candidate Downloader, Verifier, and Installer for Linux
# 
# This script:
# 1. Downloads the latest Blender Release Candidate build from builder.blender.org
# 2. Verifies the checksum
# 3. Extracts and installs
# 4. Creates a system-wide executable
#
# Requirements:
#   - lynx
#   - wget
#
################################################################################

set -e  # Exit on any error

# Configuration
BLENDER_RC_URL="https://builder.blender.org/download/daily/"
#BLENDER_RC_DOWNLOAD_DIR="/path/to/blender/download/dir"
#BLENDER_RC_INSTALL_DIR="/opt/blender/$BLENDER_RC_BIN_NAME"
#BLENDER_RC_BIN_LOCATION=/usr/local/bin
#BLENDER_RC_BIN_NAME="blender5"
PLATFORM="linux"
ARCHITECTURE="x86_64"
FILE_EXTENSION="tar.xz"

# Function to print colored output
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v lynx &> /dev/null; then
        missing_deps+=("lynx")
    fi
    
    if ! command -v wget &> /dev/null; then
        missing_deps+=("wget")
    fi
    
    if ! command -v shasum &> /dev/null; then
        print_warning "shasum not found, will use sha256sum instead"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Create and clean download directory
prepare_directories() {
    print_status "Preparing directories..."
    mkdir -p "$BLENDER_RC_DOWNLOAD_DIR"
    cd "$BLENDER_RC_DOWNLOAD_DIR"
}

# Download the latest RC build
download_rc() {
    print_status "Fetching Blender daily builds page..."
    
    # Get all links from the page
    LINKS=$(lynx -dump -listonly "$BLENDER_RC_URL" | awk '{print $2}')
    
    # Find RC binary for Linux x86_64
    RC_URL=$(echo "$LINKS" | \
        grep -i "candidate" | \
        grep -i "$PLATFORM" | \
        grep -i "$ARCHITECTURE" | \
        grep -E "\\.${FILE_EXTENSION}$" | \
        grep -v -E "\\.(sha256|sha512|md5)$" | \
        head -n 1)
    
    if [ -z "$RC_URL" ]; then
        print_error "No Release Candidate build found for $PLATFORM $ARCHITECTURE"
        exit 1
    fi
    
    # Handle relative URLs
    if [[ ! "$RC_URL" =~ ^https?:// ]]; then
        RC_URL="${BLENDER_RC_URL%/}/$RC_URL"
    fi
    
    FILENAME=$(basename "$RC_URL")
    
    print_status "Found Release Candidate build: $FILENAME"
    
    # Check if already downloaded
    if [ -f "$FILENAME" ]; then
        print_warning "File already exists, skipping download"
    else
        print_status "Downloading binary..."
        wget -c -q --show-progress "$RC_URL" || {
            print_error "Download failed"
            exit 1
        }
    fi
    
    # Export for use in other functions
    export FILENAME
    export RC_URL
}

# Download and verify checksum
verify_checksum() {
    print_status "Checking for checksum file..."
    
    # Get all links again
    LINKS=$(lynx -dump -listonly "$BLENDER_RC_URL" | awk '{print $2}')
    
    # Find corresponding checksum file
    CHECKSUM_URL=$(echo "$LINKS" | \
        grep -F "$(basename "$RC_URL")" | \
        grep -E "\\.sha256$" | \
        head -n 1)
    
    if [ -z "$CHECKSUM_URL" ]; then
        print_warning "No checksum file found, skipping verification"
        return 0
    fi
    
    # Handle relative URLs
    if [[ ! "$CHECKSUM_URL" =~ ^https?:// ]]; then
        CHECKSUM_URL="${BLENDER_RC_URL%/}/$CHECKSUM_URL"
    fi
    
    print_status "Downloading checksum..."
    wget -q "$CHECKSUM_URL" -O "${FILENAME}.sha256" || {
        print_warning "Failed to download checksum, skipping verification"
        return 0
    }
    
    print_status "Verifying checksum..."
    
    # Try shasum first (more flexible with formats)
    if command -v shasum &> /dev/null; then
        if shasum -a 256 -c "${FILENAME}.sha256" 2>/dev/null; then
            print_status "${GREEN}✓${NC} Checksum verified successfully"
            rm "${FILENAME}.sha256"
            return 0
        fi
    fi
    
    # Fallback to manual verification with sha256sum
    if command -v sha256sum &> /dev/null; then
        EXPECTED_HASH=$(cat "${FILENAME}.sha256" | awk '{print $1}' | head -n 1)
        ACTUAL_HASH=$(sha256sum "$FILENAME" | awk '{print $1}')
        
        if [ "$EXPECTED_HASH" = "$ACTUAL_HASH" ]; then
            print_status "${GREEN}✓${NC} Checksum verified successfully (manual)"
            rm "${FILENAME}.sha256"
            return 0
        else
            print_error "Checksum verification failed!"
            echo "Expected: $EXPECTED_HASH"
            echo "Actual:   $ACTUAL_HASH"
            exit 1
        fi
    fi
    
    print_warning "Could not verify checksum (no verification tools found)"
}

# Extract and install to /opt/blender/$BLENDER_RC_BIN_NAME
install_blender() {
    print_status "Installing Blender to $BLENDER_RC_INSTALL_DIR..."
    
    # Remove old installation if exists
    if [ -d "$BLENDER_RC_INSTALL_DIR" ]; then
        print_status "Removing old installation..."
        sudo rm -rf "$BLENDER_RC_INSTALL_DIR"
    fi
    
    # Create installation directory
    print_status "Creating installation directory..."
    sudo mkdir -p "$BLENDER_RC_INSTALL_DIR"
    
    # Extract with --strip-components=1 to remove top-level directory
    print_status "Extracting archive..."
    sudo tar -xf "$FILENAME" --strip-components=1 -C "$BLENDER_RC_INSTALL_DIR" || {
        print_error "Extraction failed"
        exit 1
    }
    
    print_status "${GREEN}✓${NC} Extraction complete"
}

# Create symlink for easy access
create_symlink() {
    print_status "Creating system-wide symlink..."
    
    # Create symlink in "$BLENDER_RC_BIN_LOCATION"
    if [ -L "$BLENDER_RC_BIN_LOCATION"/"$BLENDER_RC_BIN_NAME" ] || [ -f "$BLENDER_RC_BIN_LOCATION"/"$BLENDER_RC_BIN_NAME" ]; then
        sudo rm -f "$BLENDER_RC_BIN_LOCATION"/"$BLENDER_RC_BIN_NAME"
    fi
    
    sudo ln -s "$BLENDER_RC_INSTALL_DIR/blender" "$BLENDER_RC_BIN_LOCATION"/"$BLENDER_RC_BIN_NAME"
    
    print_status "${GREEN}✓${NC} Symlink created: $BLENDER_RC_BIN_LOCATION/$BLENDER_RC_BIN_NAME"
}

# Cleanup temporary files
cleanup() {
    print_status "Cleaning up temporary files..."
    cd "$HOME"
    rm -f "$BLENDER_RC_DOWNLOAD_DIR/$FILENAME"
    
    echo "delete $BLENDER_RC_DOWNLOAD_DIR?"
    PS3=$'select (1 or 2): '
    
    select deleteornot in no yes
    do case $deleteornot in
	   "no")
	       break
	       ;;
	   "yes")
	       rm -r "$BLENDER_RC_DOWNLOAD_DIR"
	       break
	       ;;
	   *)
	       print_error "Invalid selection. Please enter 1 or 2"
	       continue
	       ;;
       esac
    done
}

# Display installation summary
show_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║ Blender Latest Release Candidate Installation Complete ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "  Installation directory: $BLENDER_RC_INSTALL_DIR"
    echo "  Executable: $BLENDER_RC_BIN_LOCATION/$BLENDER_RC_BIN_NAME"
    echo ""
    echo "  Run Blender with:"
    echo "    $ $BLENDER_RC_BIN_NAME"
    echo ""
    echo "  Or directly:"
    echo "    $ $BLENDER_RC_INSTALL_DIR/blender"
    echo ""
    echo "  Uninstall by deleting the $BLENDER_RC_INSTALL_DIR directory"
    echo "  and by unlinking the $BLENDER_RC_BIN_LOCATION/$BLENDER_RC_BIN_NAME"
    echo ""
    
    # Get version if possible
    if [ -f "$BLENDER_RC_INSTALL_DIR/blender" ]; then
        VERSION=$("$BLENDER_RC_INSTALL_DIR/blender" --version 2>/dev/null | head -n 1 || echo "Version detection failed")
        echo "  Installed version: $VERSION"
        echo ""
    fi
}

# Main execution
main() {
    echo ""
    echo "╔══════════════════════════════╗"
    echo "║ Blender Latest RC Downloader ║"
    echo "╚══════════════════════════════╝"
    echo ""
    
    check_dependencies
    prepare_directories
    download_rc
    verify_checksum
    install_blender
    create_symlink
    cleanup
    show_summary
}

# Run main function
main
