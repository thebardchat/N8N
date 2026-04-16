#!/usr/bin/env bash
# =============================================================================
# ShaneBrain Ecosystem — Node Audit Script
# Run on each machine: pulsar00100, pi5, bullfrog, jaxton
#
# Usage:
#   ssh <host> 'bash -s' < scripts/audit_node.sh
#   OR copy to the machine and run: bash audit_node.sh
#
# Optional: pass machine name as argument for cleaner output
#   bash audit_node.sh pulsar00100
# =============================================================================

set -euo pipefail

NODE_NAME="${1:-$(hostname)}"
DIVIDER="========================================================================"
SECTION="------------------------------------------------------------------------"
TIMESTAMP=$(date -Iseconds)

echo "$DIVIDER"
echo "  SHANEBRAIN NODE AUDIT: $NODE_NAME"
echo "  Timestamp: $TIMESTAMP"
echo "$DIVIDER"
echo ""

# -----------------------------------------------------------------------------
# 1. SYSTEM OVERVIEW
# -----------------------------------------------------------------------------
echo "## 1. SYSTEM OVERVIEW"
echo "$SECTION"
echo "Hostname:     $(hostname)"
echo "Kernel:       $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime:      $(uptime -p 2>/dev/null || uptime)"
echo ""

# CPU
echo "CPU:"
if command -v lscpu &>/dev/null; then
    lscpu | grep -E "^(Model name|CPU\(s\)|Thread|Core)" | sed 's/^/  /'
else
    grep -c ^processor /proc/cpuinfo 2>/dev/null | xargs -I{} echo "  Cores: {}"
fi
echo ""

# Memory
echo "Memory:"
free -h | head -2
echo ""

# Load average
echo "Load Average: $(cat /proc/loadavg)"
echo ""

# Temperature (Pi / ARM boards)
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    echo "CPU Temperature: $((TEMP / 1000))C"
    echo ""
fi

# -----------------------------------------------------------------------------
# 2. STORAGE & MOUNTS
# -----------------------------------------------------------------------------
echo ""
echo "## 2. STORAGE & MOUNTS"
echo "$SECTION"

echo "### Disk Usage (all mounted filesystems):"
df -hT | grep -vE "^(tmpfs|devtmpfs|overlay)" | head -30
echo ""

echo "### Block Devices:"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null || lsblk
echo ""

echo "### USB / External Drives:"
if command -v lsusb &>/dev/null; then
    lsusb 2>/dev/null | grep -iE "storage|mass|external|seagate|western|sandisk|samsung|toshiba|crucial" || echo "  (no USB storage devices detected — full lsusb below)"
    lsusb 2>/dev/null | head -15
else
    echo "  lsusb not available"
fi
echo ""

# RAID check
echo "### RAID Status:"
if [ -f /proc/mdstat ]; then
    echo "  /proc/mdstat:"
    cat /proc/mdstat | sed 's/^/  /'
elif command -v mdadm &>/dev/null; then
    mdadm --detail --scan 2>/dev/null | sed 's/^/  /' || echo "  mdadm found but no arrays"
elif command -v zpool &>/dev/null; then
    echo "  ZFS pools:"
    zpool status 2>/dev/null | sed 's/^/  /' || echo "  zpool found but no pools"
elif command -v btrfs &>/dev/null; then
    echo "  Btrfs filesystems:"
    btrfs filesystem show 2>/dev/null | sed 's/^/  /' || echo "  btrfs found but no multi-device arrays"
else
    echo "  No RAID (mdadm/zfs/btrfs) detected"
fi
echo ""

# Large directories
echo "### Top 10 largest directories in /home (if accessible):"
du -sh /home/*/ 2>/dev/null | sort -rh | head -10 || echo "  (could not scan /home)"
echo ""

# -----------------------------------------------------------------------------
# 3. ZOMBIE & ORPHAN PROCESSES
# -----------------------------------------------------------------------------
echo ""
echo "## 3. ZOMBIE & ORPHAN PROCESSES"
echo "$SECTION"

ZOMBIE_COUNT=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
echo "Zombie processes: $ZOMBIE_COUNT"
if [ "$ZOMBIE_COUNT" -gt 0 ]; then
    echo ""
    echo "### Zombie process details:"
    ps aux | awk 'NR==1 || $8 ~ /Z/' | head -20
    echo ""
    echo "### Parent processes of zombies:"
    ps aux | awk '$8 ~ /Z/ {print $2}' | while read zpid; do
        PPID_OF_Z=$(ps -o ppid= -p "$zpid" 2>/dev/null | tr -d ' ')
        if [ -n "$PPID_OF_Z" ]; then
            echo "  Zombie PID $zpid -> Parent PID $PPID_OF_Z: $(ps -o comm= -p "$PPID_OF_Z" 2>/dev/null)"
        fi
    done
fi
echo ""

# Long-running processes (over 24h)
echo "### Long-running processes (>24h, non-system):"
ps -eo pid,etimes,user,comm --sort=-etimes 2>/dev/null | awk 'NR==1 || ($2 > 86400 && $3 != "root")' | head -20 || echo "  (could not query)"
echo ""

# Top CPU consumers
echo "### Top 15 CPU consumers:"
ps aux --sort=-%cpu | head -16
echo ""

# Top memory consumers
echo "### Top 15 memory consumers:"
ps aux --sort=-%mem | head -16
echo ""

# Defunct / stuck processes
echo "### Processes in D (uninterruptible sleep) state:"
DSTATE=$(ps aux | awk '$8 ~ /D/ && NR>1')
if [ -n "$DSTATE" ]; then
    ps aux | awk 'NR==1 || $8 ~ /D/' | head -10
else
    echo "  None"
fi
echo ""

# -----------------------------------------------------------------------------
# 4. DOCKER CONTAINERS
# -----------------------------------------------------------------------------
echo ""
echo "## 4. DOCKER CONTAINERS"
echo "$SECTION"

if command -v docker &>/dev/null; then
    echo "### Running containers:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  (docker permission denied — try with sudo)"
    echo ""

    echo "### All containers (including stopped):"
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Size}}" 2>/dev/null || echo "  (docker permission denied)"
    echo ""

    echo "### Docker disk usage:"
    docker system df 2>/dev/null || echo "  (could not query)"
    echo ""

    echo "### Dangling images / unused volumes:"
    DANGLING=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l)
    UNUSED_VOL=$(docker volume ls -f "dangling=true" -q 2>/dev/null | wc -l)
    echo "  Dangling images: $DANGLING"
    echo "  Unused volumes:  $UNUSED_VOL"
    echo ""

    echo "### Container resource usage (live):"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null || echo "  (could not query)"
else
    echo "  Docker not installed on this node"
fi
echo ""

# -----------------------------------------------------------------------------
# 5. NETWORK & LISTENING SERVICES
# -----------------------------------------------------------------------------
echo ""
echo "## 5. NETWORK & LISTENING SERVICES"
echo "$SECTION"

echo "### All listening ports:"
if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | head -40
elif command -v netstat &>/dev/null; then
    netstat -tlnp 2>/dev/null | head -40
else
    echo "  Neither ss nor netstat available"
fi
echo ""

# Tailscale
echo "### Tailscale status:"
if command -v tailscale &>/dev/null; then
    tailscale status 2>/dev/null | head -20 || echo "  Tailscale installed but not connected"
else
    echo "  Tailscale not installed"
fi
echo ""

# -----------------------------------------------------------------------------
# 6. SYSTEMD SERVICES & FAILED UNITS
# -----------------------------------------------------------------------------
echo ""
echo "## 6. SYSTEMD SERVICES"
echo "$SECTION"

if command -v systemctl &>/dev/null; then
    echo "### Failed units:"
    systemctl --failed 2>/dev/null | head -20 || echo "  (could not query)"
    echo ""

    echo "### ShaneBrain-related services:"
    systemctl list-units --type=service --state=running 2>/dev/null | grep -iE "n8n|shanebrain|weaviate|ollama|redis|postgres|nginx|caddy|discord" || echo "  (none found as systemd services)"
else
    echo "  systemd not available"
fi
echo ""

# -----------------------------------------------------------------------------
# 7. CRON JOBS & SCHEDULED TASKS
# -----------------------------------------------------------------------------
echo ""
echo "## 7. SCHEDULED TASKS"
echo "$SECTION"

echo "### Current user crontab:"
crontab -l 2>/dev/null || echo "  No crontab"
echo ""

echo "### System cron jobs:"
for f in /etc/crontab /etc/cron.d/*; do
    if [ -f "$f" ]; then
        echo "  --- $f ---"
        grep -v '^#' "$f" 2>/dev/null | grep -v '^$' | sed 's/^/  /'
    fi
done
echo ""

# Systemd timers
if command -v systemctl &>/dev/null; then
    echo "### Systemd timers:"
    systemctl list-timers --all 2>/dev/null | head -20 || echo "  (could not query)"
fi
echo ""

# -----------------------------------------------------------------------------
# 8. OLLAMA STATUS (for cluster nodes)
# -----------------------------------------------------------------------------
echo ""
echo "## 8. OLLAMA STATUS"
echo "$SECTION"

if command -v ollama &>/dev/null; then
    echo "Ollama version: $(ollama --version 2>/dev/null || echo 'unknown')"
    echo ""
    echo "### Running models:"
    ollama ps 2>/dev/null || echo "  (could not query)"
    echo ""
    echo "### Installed models:"
    ollama list 2>/dev/null || echo "  (could not query)"
elif curl -s --max-time 3 http://localhost:11434/api/tags &>/dev/null; then
    echo "Ollama responding on :11434 (no CLI found):"
    curl -s --max-time 5 http://localhost:11434/api/tags 2>/dev/null | head -50
else
    echo "  Ollama not found on this node"
fi
echo ""

# -----------------------------------------------------------------------------
# 9. PYTHON / NODE ENVIRONMENTS
# -----------------------------------------------------------------------------
echo ""
echo "## 9. RUNTIME ENVIRONMENTS"
echo "$SECTION"

echo "Python:"
command -v python3 &>/dev/null && python3 --version 2>&1 | sed 's/^/  /' || echo "  not installed"
command -v pip3 &>/dev/null && echo "  pip3: $(pip3 --version 2>&1)" || true

echo ""
echo "Node.js:"
command -v node &>/dev/null && echo "  $(node --version)" || echo "  not installed"
command -v pnpm &>/dev/null && echo "  pnpm: $(pnpm --version 2>&1)" || true
command -v npm &>/dev/null && echo "  npm: $(npm --version 2>&1)" || true

echo ""
echo "Docker:"
command -v docker &>/dev/null && docker --version 2>&1 | sed 's/^/  /' || echo "  not installed"
command -v docker-compose &>/dev/null && docker-compose --version 2>&1 | sed 's/^/  /' || true
docker compose version 2>/dev/null | sed 's/^/  /' || true
echo ""

# -----------------------------------------------------------------------------
# 10. QUICK SECURITY CHECK
# -----------------------------------------------------------------------------
echo ""
echo "## 10. QUICK SECURITY SCAN"
echo "$SECTION"

echo "### SSH authorized keys:"
if [ -f ~/.ssh/authorized_keys ]; then
    wc -l < ~/.ssh/authorized_keys | xargs -I{} echo "  {} authorized keys"
else
    echo "  No authorized_keys file"
fi

echo ""
echo "### Users with login shells:"
grep -v '/nologin\|/false' /etc/passwd 2>/dev/null | awk -F: '{print "  "$1" ("$7")"}' | head -15

echo ""
echo "### Last 10 logins:"
last -10 2>/dev/null || echo "  (could not query)"

echo ""
echo "### Listening on 0.0.0.0 (exposed to network):"
if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | grep "0.0.0.0" | head -20 || echo "  none"
else
    echo "  (ss not available)"
fi
echo ""

# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------
echo ""
echo "$DIVIDER"
echo "  AUDIT COMPLETE: $NODE_NAME"
echo "  Finished: $(date -Iseconds)"
echo "$DIVIDER"
echo ""
echo "To save this output:"
echo "  bash audit_node.sh $NODE_NAME > audit_${NODE_NAME}_\$(date +%Y%m%d).txt"
