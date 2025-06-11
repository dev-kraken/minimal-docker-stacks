#!/bin/bash
# WordPress Docker Monitoring Script
# Author: DevKraken (soman@devkraken.com)
# Version: 1.0

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/logs/monitor.log"
readonly COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"
readonly ALERT_THRESHOLD_CPU=80
readonly ALERT_THRESHOLD_MEMORY=85
readonly ALERT_THRESHOLD_DISK=90

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Initialize logging
mkdir -p "$(dirname "$LOG_FILE")"

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
}

# Check if docker compose is available
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        log_error "docker not found. Please install Docker."
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        log_error "docker compose not found. Please install Docker Compose plugin."
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running or accessible."
        exit 1
    fi
}

# Get container stats
get_container_stats() {
    local container_name="$1"
    
    if ! docker ps --format "table {{.Names}}" | grep -q "$container_name"; then
        echo "Container not running"
        return 1
    fi
    
    # Get container stats (one-time snapshot)
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" "$container_name"
}

# Monitor container health
monitor_container_health() {
    local container_name="$1"
    local service_name="$2"
    
    log_info "Checking health of $service_name ($container_name)"
    
    # Check if container is running
    if ! docker ps --format "table {{.Names}}" | grep -q "$container_name"; then
        log_error "$service_name container is not running"
        return 1
    fi
    
    # Check container health status
    local health_status
    health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
    
    case "$health_status" in
        "healthy")
            log_info "$service_name is healthy"
            ;;
        "unhealthy")
            log_error "$service_name is unhealthy"
            return 1
            ;;
        "starting")
            log_warn "$service_name is starting..."
            ;;
        "no-healthcheck")
            log_debug "$service_name has no health check configured"
            ;;
    esac
    
    # Get resource usage
    local stats
    stats=$(get_container_stats "$container_name" 2>/dev/null || echo "Failed to get stats")
    
    if [[ "$stats" != "Failed to get stats" ]] && [[ "$stats" != "Container not running" ]]; then
        echo "$stats"
        
        # Extract CPU and memory percentages for alerting
        local cpu_usage memory_usage
        cpu_usage=$(echo "$stats" | tail -n 1 | awk '{print $2}' | sed 's/%//')
        memory_usage=$(echo "$stats" | tail -n 1 | awk '{print $4}' | sed 's/%//')
        
        # CPU threshold check
        if (( $(echo "$cpu_usage >= $ALERT_THRESHOLD_CPU" | bc -l 2>/dev/null || echo "0") )); then
            log_warn "$service_name CPU usage is high: ${cpu_usage}%"
        fi
        
        # Memory threshold check
        if (( $(echo "$memory_usage >= $ALERT_THRESHOLD_MEMORY" | bc -l 2>/dev/null || echo "0") )); then
            log_warn "$service_name Memory usage is high: ${memory_usage}%"
        fi
    else
        log_error "Could not retrieve stats for $service_name"
    fi
    
    echo
}

# Check disk usage
check_disk_usage() {
    log_info "Checking disk usage"
    
    # Check overall disk usage
    local disk_usage
    disk_usage=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
    
    log_info "Current disk usage: ${disk_usage}%"
    
    if [[ $disk_usage -gt $ALERT_THRESHOLD_DISK ]]; then
        log_error "Disk usage is critically high: ${disk_usage}%"
    elif [[ $disk_usage -gt 75 ]]; then
        log_warn "Disk usage is getting high: ${disk_usage}%"
    fi
    
    # Check Docker volumes
    log_info "Docker volume usage:"
    docker system df
    
    echo
}

# Check log file sizes
check_log_sizes() {
    log_info "Checking log file sizes"
    
    local logs_dir="${SCRIPT_DIR}/logs"
    
    if [[ -d "$logs_dir" ]]; then
        find "$logs_dir" -name "*.log" -type f -exec ls -lh {} + 2>/dev/null | while read -r line; do
            local size=$(echo "$line" | awk '{print $5}')
            local file=$(echo "$line" | awk '{print $9}')
            echo "  $file: $size"
            
            # Alert on large log files (>100MB)
            local size_mb
            size_mb=$(echo "$line" | awk '{print $5}' | sed 's/[^0-9.]//g')
            if [[ "$size" == *G ]] || [[ $(echo "$size_mb > 100" | bc -l 2>/dev/null || echo "0") == "1" ]]; then
                log_warn "Large log file detected: $file ($size)"
            fi
        done
    else
        log_info "No logs directory found at $logs_dir"
    fi
    
    echo
}

# Check WordPress connectivity
check_wordpress_connectivity() {
    log_info "Testing WordPress connectivity"
    
    # Try to get WordPress container port
    local wp_container_name
    wp_container_name=$(docker compose ps -q wordpress 2>/dev/null || echo "")
    
    if [[ -z "$wp_container_name" ]]; then
        log_error "WordPress container not found"
        return 1
    fi
    
    # Test internal connectivity
    if docker exec "$wp_container_name" curl -f -s http://localhost:8080 >/dev/null 2>&1; then
        log_info "WordPress internal connectivity: OK"
    else
        log_error "WordPress internal connectivity: FAILED"
        return 1
    fi
    
    # Test admin access
    if docker exec "$wp_container_name" curl -f -s http://localhost:8080/wp-admin/ >/dev/null 2>&1; then
        log_info "WordPress admin accessibility: OK"
    else
        log_warn "WordPress admin accessibility: LIMITED (may be normal if not installed)"
    fi
    
    echo
}

# Generate monitoring report
generate_report() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE} WordPress Docker Monitoring Report${NC}"
    echo -e "${PURPLE} Generated: $timestamp${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo
    
    # Load environment for container names
    if [[ -f .env ]]; then
        source .env
    fi
    
    local wp_container="${WORDPRESS_CONTAINER_NAME:-wp_app}"
    local mysql_container="${MYSQL_CONTAINER_NAME:-wp_mysql}"
    local nginx_container="${NGINX_CONTAINER_NAME:-wp_nginx}"
    
    # Monitor each service
    monitor_container_health "$wp_container" "WordPress"
    monitor_container_health "$mysql_container" "MySQL"
    monitor_container_health "$nginx_container" "Nginx"
    
    # System checks
    check_disk_usage
    check_log_sizes
    check_wordpress_connectivity
    
    log_info "Monitoring complete at $timestamp"
}

# Cleanup old logs
cleanup_logs() {
    log_info "Cleaning up old monitoring logs"
    
    # Keep last 30 days of monitoring logs
    find "$(dirname "$LOG_FILE")" -name "monitor.log.*" -mtime +30 -delete 2>/dev/null || true
    
    # Rotate current log if it's too large (>10MB)
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt 10485760 ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d_%H%M%S)"
        touch "$LOG_FILE"
        log_info "Rotated large monitor log file"
    fi
}

# Show help
show_help() {
    echo "WordPress Docker Monitoring Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -q, --quiet         Quiet mode (log to file only)"
    echo "  -c, --continuous    Continuous monitoring (runs every 60 seconds)"
    echo "  --cleanup          Clean up old log files"
    echo
    echo "Examples:"
    echo "  $0                  Run monitoring once"
    echo "  $0 -c              Run continuous monitoring"
    echo "  $0 --cleanup       Clean up old logs"
}

# Main function
main() {
    local quiet_mode=false
    local continuous_mode=false
    local cleanup_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            -c|--continuous)
                continuous_mode=true
                shift
                ;;
            --cleanup)
                cleanup_mode=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Check dependencies
    check_dependencies
    
    # Handle cleanup mode
    if [[ "$cleanup_mode" == true ]]; then
        cleanup_logs
        exit 0
    fi
    
    # Redirect output if quiet mode
    if [[ "$quiet_mode" == true ]]; then
        exec > /dev/null 2>&1
    fi
    
    # Handle continuous monitoring
    if [[ "$continuous_mode" == true ]]; then
        log_info "Starting continuous monitoring (Ctrl+C to stop)"
        
        while true; do
            generate_report
            sleep 60
        done
    else
        # Single run
        generate_report
    fi
}

# Handle interrupts gracefully
trap 'echo; log_info "Monitoring stopped by user"; exit 0' INT TERM

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 