#!/usr/bin/env bash
# =============================================================================
# Run the node audit across all ShaneBrain machines
#
# Prerequisites:
#   - SSH key access to each host (no password prompts)
#   - Tailscale or local network connectivity
#
# Usage:
#   bash scripts/audit_all_nodes.sh
#
# Edit the NODES array below to match your actual hostnames/IPs
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIT_SCRIPT="$SCRIPT_DIR/audit_node.sh"
OUTPUT_DIR="$SCRIPT_DIR/../audit_results"
DATE_TAG=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

# ---- EDIT THESE TO MATCH YOUR HOSTS ----
# Format: "friendly_name:ssh_target"
# ssh_target can be hostname, IP, or user@host
NODES=(
    "pulsar00100:pulsar00100"
    "pi5:pi5"
    "bullfrog:bullfrog"
    "jaxton:jaxton"
)
# -----------------------------------------

echo "============================================"
echo "  ShaneBrain Fleet Audit"
echo "  Date: $(date)"
echo "============================================"
echo ""
echo "Targets: ${NODES[*]}"
echo "Results will be saved to: $OUTPUT_DIR/"
echo ""

FAILED=()
SUCCEEDED=()

for entry in "${NODES[@]}"; do
    NAME="${entry%%:*}"
    HOST="${entry##*:}"
    OUTFILE="$OUTPUT_DIR/audit_${NAME}_${DATE_TAG}.txt"

    echo "--- Auditing $NAME ($HOST) ---"

    # Test SSH connectivity first (3 second timeout)
    if ssh -o ConnectTimeout=5 -o BatchMode=yes "$HOST" "echo ok" &>/dev/null; then
        echo "  SSH connected. Running audit..."
        ssh -o ConnectTimeout=10 "$HOST" 'bash -s' "$NAME" < "$AUDIT_SCRIPT" > "$OUTFILE" 2>&1
        if [ $? -eq 0 ]; then
            echo "  Saved: $OUTFILE"
            SUCCEEDED+=("$NAME")
        else
            echo "  WARNING: Audit ran but had errors. Partial output in: $OUTFILE"
            SUCCEEDED+=("$NAME (partial)")
        fi
    else
        echo "  FAILED: Cannot SSH to $HOST — skipping"
        echo "  Check: ssh $HOST"
        FAILED+=("$NAME")
    fi
    echo ""
done

# Also audit localhost if this IS one of the nodes
echo "--- Auditing localhost ---"
OUTFILE="$OUTPUT_DIR/audit_localhost_${DATE_TAG}.txt"
bash "$AUDIT_SCRIPT" "localhost" > "$OUTFILE" 2>&1
echo "  Saved: $OUTFILE"
echo ""

# Summary
echo "============================================"
echo "  FLEET AUDIT SUMMARY"
echo "============================================"
echo "  Succeeded: ${SUCCEEDED[*]:-none}"
echo "  Failed:    ${FAILED[*]:-none}"
echo "  Localhost:  done"
echo ""
echo "  All results in: $OUTPUT_DIR/"
echo ""
echo "  Quick review:"
echo "    grep -h 'Zombie processes' $OUTPUT_DIR/audit_*_${DATE_TAG}.txt"
echo "    grep -h 'Load Average' $OUTPUT_DIR/audit_*_${DATE_TAG}.txt"
echo ""

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "  To fix failed connections:"
    for f in "${FAILED[@]}"; do
        echo "    ssh-copy-id $f    # if key not set up"
        echo "    tailscale ping $f  # if using Tailscale"
    done
fi
