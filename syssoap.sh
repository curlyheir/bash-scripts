#!/bin/bash

# Linux Disk Cleanup Script
# Clears temporary files, caches, old logs, and tracks freed space.
# Run with sudo for full system cleanup (e.g., sudo ./syssoap.sh)

# Ensure running as root for system-wide cleanup
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g., sudo $0)"
    exit 1
fi

# Configuration
LOG_FILE="/var/log/cleanup_$(date +%Y%m%d_%H%M).log"
TOTAL_SAVED=0

log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

get_size() {
    if [[ -e $1 ]]; then
        du -sk "$1" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

delete_safely() {
    local path="$1"
    local desc="$2"
    
    if [[ -e "$path" ]]; then
        local size_before=$(get_size "$path")
        rm -rf "$path" 2>/dev/null
        local freed=$((size_before))
        TOTAL_SAVED=$((TOTAL_SAVED + freed))
        log_message "Cleaned $desc - Freed $((freed/1024)) MB"
    fi
}

log_message "Server cleanup started at $(date)"
log_message "Hostname: $(hostname)"

# 1. Clean System Temporary Files
log_message "\nCleaning temporary files..."
TEMP_PATHS=("/tmp" "/var/tmp")
for path in "${TEMP_PATHS[@]}"; do
    if [[ -d "$path" ]]; then
        delete_safely "$path" "temp directory: $path"
    fi
done

# 2. Clean Package Manager Caches
log_message "\nCleaning package manager caches..."
if command -v apt-get &> /dev/null; then
    apt-get clean 2>/dev/null
    apt-get autoremove -y 2>/dev/null
    log_message "Cleaned APT cache"
elif command -v dnf &> /dev/null; then
    dnf clean all 2>/dev/null
    log_message "Cleaned DNF cache"
elif command -v yum &> /dev/null; then
    yum clean all 2>/dev/null
    log_message "Cleaned YUM cache"
fi

# 3. Clean Old Logs (Keep recent logs, remove archives)
log_message "\nCleaning old logs..."
if [[ -d "/var/log" ]]; then
    # Remove compressed/old logs older than 30 days
    find /var/log -type f \( -name "*.gz" -o -name "*.old" -o -name "*.log.*" \) -mtime +30 -delete 2>/dev/null
    # Truncate large active logs (optional, use with caution)
    # find /var/log -type f -name "*.log" -size +100M -exec truncate -s 0 {} \;
    log_message "Cleaned old logs in /var/log"
fi

# 4. Clean Systemd Journal Logs
log_message "\nCleaning journald logs..."
if command -v journalctl &> /dev/null; then
    journalctl --vacuum-time=30d >/dev/null 2>&1
    log_message "Vacuumed journald logs to last 30 days"
fi

# 5. Clean Docker Resources (If installed)
log_message "\nCleaning Docker resources..."
if command -v docker &> /dev/null; then
    docker system prune -af --volumes >/dev/null 2>&1
    log_message "Pruned Docker images, containers, and volumes"
fi

# 6. Clean User Cache (Optional, run without sudo or for specific user)
# Note: This section is commented out as it requires user context.
# Uncomment and run as the specific user to clean their cache.
# log_message "\nCleaning user cache..."
# rm -rf ~/.cache/* 2>/dev/null

# Final Summary
TOTAL_GB=$(echo "scale=2; $TOTAL_SAVED/1024/1024" | bc)
log_message "\nCleanup completed at $(date)"
log_message "Total space saved: ${TOTAL_GB} GB"
log_message "Log file saved to: $LOG_FILE"

echo "Cleanup complete. Total space saved: ${TOTAL_GB} GB"
echo "Details logged to: $LOG_FILE"   
