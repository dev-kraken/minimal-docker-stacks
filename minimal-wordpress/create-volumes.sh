#!/bin/bash
# WordPress Docker Volume Creation Script
# Author: DevKraken (soman@devkraken.com)
# Version: 2.0

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Error handling
handle_error() {
    log_error "Script failed at line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or accessible. Please start Docker first."
        exit 1
    fi
    log_info "Docker is running"
}

# Load environment variables from .env file
load_environment() {
    if [[ -f .env ]]; then
        log_info "Loading environment from .env file"
        # Source the .env file to properly expand variables
        set -a  # automatically export all variables
        source .env
        set +a  # turn off automatic export
        log_debug "Environment variables loaded and expanded"
    else
        log_warn ".env file not found. Using default values."
    fi
}

# Validate volume names
validate_volume_name() {
    local volume_name="$1"
    local var_name="$2"
    
    # Check if volume name is valid (Docker naming rules)
    if [[ ! $volume_name =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
        log_error "Invalid volume name '$volume_name' for $var_name. Must start with alphanumeric and contain only [a-zA-Z0-9_.-]"
        exit 1
    fi
    
    # Check length (Docker volume names should be reasonable)
    if [[ ${#volume_name} -gt 64 ]]; then
        log_error "Volume name '$volume_name' is too long (max 64 characters)"
        exit 1
    fi
    
    log_debug "Volume name '$volume_name' is valid"
}

# Check if volume already exists
volume_exists() {
    local volume_name="$1"
    docker volume inspect "$volume_name" >/dev/null 2>&1
}

# Create volume with error handling
create_volume() {
    local volume_name="$1"
    local description="$2"
    
    if volume_exists "$volume_name"; then
        log_warn "$description volume '$volume_name' already exists. Skipping creation."
        return 0
    fi
    
    log_info "Creating $description volume: $volume_name"
    
    if docker volume create "$volume_name" >/dev/null; then
        log_info "✓ Successfully created $description volume: $volume_name"
    else
        log_error "Failed to create $description volume: $volume_name"
        exit 1
    fi
}

# Display volume information
show_volume_info() {
    local volume_name="$1"
    local description="$2"
    
    if volume_exists "$volume_name"; then
        local mount_point
        mount_point=$(docker volume inspect "$volume_name" --format '{{ .Mountpoint }}' 2>/dev/null || echo "Unknown")
        log_info "$description volume '$volume_name' mountpoint: $mount_point"
    fi
}

# Main function
main() {
    log_info "WordPress Docker Volume Creator v2.0"
    log_info "========================================"
    
    # Preflight checks
    check_docker
    load_environment
    
    # Set default values if not provided
    local mysql_volume_name="${MYSQL_VOLUME_NAME:-devkraken_mysql_data}"
    local wordpress_volume_name="${WORDPRESS_VOLUME_NAME:-devkraken_wordpress_data}"
    
    # Validate volume names
    validate_volume_name "$mysql_volume_name" "MYSQL_VOLUME_NAME"
    validate_volume_name "$wordpress_volume_name" "WORDPRESS_VOLUME_NAME"
    
    # Check for volume name conflicts
    if [[ "$mysql_volume_name" == "$wordpress_volume_name" ]]; then
        log_error "MySQL and WordPress volume names cannot be the same: $mysql_volume_name"
        exit 1
    fi
    
    log_info "Creating Docker volumes with the following names:"
    log_info "  MySQL volume: $mysql_volume_name"
    log_info "  WordPress volume: $wordpress_volume_name"
    echo
    
    # Create volumes
    create_volume "$mysql_volume_name" "MySQL"
    create_volume "$wordpress_volume_name" "WordPress"
    
    echo
    log_info "Volume creation completed!"
    
    # Show volume information
    echo
    log_info "Volume Information:"
    show_volume_info "$mysql_volume_name" "MySQL"
    show_volume_info "$wordpress_volume_name" "WordPress"
    
    echo
    log_info "Next steps:"
    log_info "1. Review your .env configuration"
    log_info "2. Run: docker compose up -d"
    log_info "3. Monitor with: docker compose logs -f"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 