#!/bin/sh
# WordPress PHP-FPM Health Check Script
# Author: DevKraken (soman@devkraken.com)
# Professional health monitoring for containerized WordPress

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PHP_FPM_HOST="127.0.0.1"
PHP_FPM_PORT="9000"
WORDPRESS_ROOT="/var/www/html"
MAX_RESPONSE_TIME=5
EXIT_CODE=0

# Logging function
log() {
    echo "${1}[$(date '+%Y-%m-%d %H:%M:%S')] $2${NC}"
}

# Check if PHP-FPM process is running
check_php_fpm_process() {
    log "$BLUE" "Checking PHP-FPM process..."
    
    if pgrep -x "php-fpm" > /dev/null; then
        log "$GREEN" "✓ PHP-FPM process is running"
        return 0
    else
        log "$RED" "✗ PHP-FPM process not found"
        return 1
    fi
}

# Check PHP-FPM socket connectivity
check_php_fpm_socket() {
    log "$BLUE" "Checking PHP-FPM socket connectivity..."
    
    # Test if PHP-FPM is listening on port 9000
    if nc -z $PHP_FPM_HOST $PHP_FPM_PORT 2>/dev/null; then
        log "$GREEN" "✓ PHP-FPM socket is accessible on $PHP_FPM_HOST:$PHP_FPM_PORT"
        return 0
    else
        log "$RED" "✗ PHP-FPM socket not accessible on $PHP_FPM_HOST:$PHP_FPM_PORT"
        return 1
    fi
}

# Check WordPress files
check_wordpress_files() {
    log "$BLUE" "Checking WordPress core files..."
    
    # Check if WordPress core files exist
    if [ -f "$WORDPRESS_ROOT/wp-config.php" ] && [ -f "$WORDPRESS_ROOT/index.php" ]; then
        log "$GREEN" "✓ WordPress core files present"
        return 0
    else
        log "$RED" "✗ WordPress core files missing"
        return 1
    fi
}

# Check file permissions
check_permissions() {
    log "$BLUE" "Checking file permissions..."
    
    # Check if we can read WordPress files
    if [ -r "$WORDPRESS_ROOT/index.php" ]; then
        log "$GREEN" "✓ WordPress files are readable"
        return 0
    else
        log "$RED" "✗ WordPress files permission issues"
        return 1
    fi
}

# Check available disk space
check_disk_space() {
    log "$BLUE" "Checking disk space..."
    
    # Get disk usage percentage (remove % sign)
    DISK_USAGE=$(df $WORDPRESS_ROOT | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -lt 90 ]; then
        log "$GREEN" "✓ Disk space OK ($DISK_USAGE% used)"
        return 0
    else
        log "$YELLOW" "⚠ Disk space warning ($DISK_USAGE% used)"
        return 1
    fi
}

# Check memory usage
check_memory() {
    log "$BLUE" "Checking memory usage..."
    
    # Get memory usage if available
    if command -v free >/dev/null 2>&1; then
        MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
        if [ "$MEM_USAGE" -lt 90 ]; then
            log "$GREEN" "✓ Memory usage OK ($MEM_USAGE%)"
            return 0
        else
            log "$YELLOW" "⚠ Memory usage high ($MEM_USAGE%)"
            return 1
        fi
    else
        log "$BLUE" "ℹ Memory check not available"
        return 0
    fi
}

# Main health check function
main() {
    log "$BLUE" "Starting WordPress PHP-FPM health check..."
    echo ""
    
    # Critical checks (must pass)
    check_php_fpm_process || EXIT_CODE=1
    check_php_fpm_socket || EXIT_CODE=1
    check_wordpress_files || EXIT_CODE=1
    check_permissions || EXIT_CODE=1
    
    # Warning checks (don't fail health check)
    check_disk_space || log "$YELLOW" "⚠ Consider monitoring disk space"
    check_memory || log "$YELLOW" "⚠ Consider monitoring memory usage"
    
    echo ""
    if [ $EXIT_CODE -eq 0 ]; then
        log "$GREEN" "✓ All health checks passed - PHP-FPM container is healthy"
    else
        log "$RED" "✗ Health check failed - PHP-FPM container needs attention"
    fi
    
    exit $EXIT_CODE
}

# Run main function
main "$@" 