#!/bin/bash
# deploy-global-claude-md.sh
# Pushes the global CLAUDE.md to all active thebardchat repos
# Run from Pi 5 or any machine with GitHub access
#
# Usage: ./deploy-global-claude-md.sh [path-to-global-claude-md]
# Default: ~/.claude/CLAUDE.md

set -euo pipefail

SOURCE="${1:-$HOME/.claude/CLAUDE.md}"
ORG="thebardchat"
COMMIT_MSG="chore: add global CLAUDE.md — ShaneBrain ecosystem directive"
LOG_FILE="$(dirname "$0")/deploy-claude-md.log"

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source file not found: $SOURCE"
    exit 1
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Deploying global CLAUDE.md to all $ORG repos ==="
log "Source: $SOURCE"

# Active repos — skip archived, forks, and N8N (has its own)
ACTIVE_REPOS=(
    "shanebrain-core"
    "shanebrain_mcp"
    "angel-cloud"
    "HaloFinance"
    "MASTER-Scheduler-Dashboard-SRM"
    "SB-Management-OS"
    "mini-shanebrain"
    "thought-tree"
    "pulsar_sentinel"
    "shanebrain-backup"
    "AI-Trainer-MAX"
    "angel-cloud-roblox"
    "book-launch-playbook"
    "noir-detective-writing-process"
    "BGKPJR-Core-Simulations"
    "loudon-desarro"
    "angel-cloud-auth-bridge"
    "constitution"
    "thebardchat.github.io"
    "srm-dispatch"
)

SUCCEEDED=0
FAILED=0
SKIPPED=0

for REPO in "${ACTIVE_REPOS[@]}"; do
    TEMP_DIR=$(mktemp -d)
    log "--- $REPO ---"

    # Clone shallow
    if ! git clone --depth 1 "https://github.com/$ORG/$REPO.git" "$TEMP_DIR" 2>/dev/null; then
        log "  SKIP: Could not clone $REPO (archived or private)"
        rm -rf "$TEMP_DIR"
        ((SKIPPED++))
        continue
    fi

    cd "$TEMP_DIR"

    # Check if CLAUDE.md already exists and is identical
    if [[ -f "CLAUDE.md" ]]; then
        if diff -q "$SOURCE" "CLAUDE.md" >/dev/null 2>&1; then
            log "  SKIP: CLAUDE.md already up to date"
            rm -rf "$TEMP_DIR"
            ((SKIPPED++))
            continue
        fi
        log "  UPDATE: CLAUDE.md exists but differs — updating"
    else
        log "  CREATE: Adding CLAUDE.md"
    fi

    # Copy and commit
    cp "$SOURCE" "CLAUDE.md"
    git add CLAUDE.md
    git commit -m "$COMMIT_MSG" 2>/dev/null

    if git push origin HEAD 2>/dev/null; then
        log "  OK: Pushed to $REPO"
        ((SUCCEEDED++))
    else
        log "  FAIL: Push failed for $REPO"
        ((FAILED++))
    fi

    cd /
    rm -rf "$TEMP_DIR"
done

log ""
log "=== Deploy complete ==="
log "Succeeded: $SUCCEEDED"
log "Failed: $FAILED"
log "Skipped: $SKIPPED"
log "Total repos: ${#ACTIVE_REPOS[@]}"
