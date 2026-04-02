#!/bin/bash
# daily-claude-sync.sh — Runs at 05:00 AM via cron
# Syncs global ~/.claude/CLAUDE.md with repo CLAUDE.md
# Checks for new thebardchat repos on GitHub
# Commits and pushes any changes

set -euo pipefail

GLOBAL_MD="/home/user/.claude/CLAUDE.md"
REPO_DIR="/home/user/N8N"
REPO_MD="$REPO_DIR/CLAUDE.md"
LOG_FILE="/home/user/N8N/scripts/sync.log"
GITHUB_ORG="thebardchat"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "=== Daily CLAUDE.md sync started ==="

# --- 1. Check both files exist ---
if [[ ! -f "$GLOBAL_MD" ]]; then
    log "ERROR: Global CLAUDE.md not found at $GLOBAL_MD"
    exit 1
fi

if [[ ! -f "$REPO_MD" ]]; then
    log "ERROR: Repo CLAUDE.md not found at $REPO_MD"
    exit 1
fi

# --- 2. Pull latest repo changes ---
cd "$REPO_DIR"
git pull origin main --quiet 2>/dev/null || log "WARN: git pull failed or no remote changes"

# --- 3. Extract service endpoints from repo CLAUDE.md and compare ---
# Get checksums to detect drift
GLOBAL_HASH=$(md5sum "$GLOBAL_MD" | cut -d' ' -f1)
REPO_HASH=$(md5sum "$REPO_MD" | cut -d' ' -f1)

CHANGES_MADE=false

# --- 4. Sync cluster/endpoint info from repo → global ---
# Extract key sections from repo CLAUDE.md that should be in global
# Compare "The Cluster" and "Integration Points" sections

# Check if repo has IPs/ports not in global
REPO_IPS=$(grep -oP '\d+\.\d+\.\d+\.\d+[:\d]*' "$REPO_MD" 2>/dev/null | sort -u)
GLOBAL_IPS=$(grep -oP '\d+\.\d+\.\d+\.\d+[:\d]*' "$GLOBAL_MD" 2>/dev/null | sort -u)

NEW_IPS=$(comm -23 <(echo "$REPO_IPS") <(echo "$GLOBAL_IPS") 2>/dev/null || true)
if [[ -n "$NEW_IPS" ]]; then
    log "Found new IPs/endpoints in repo not in global: $NEW_IPS"
    log "ACTION NEEDED: Review and manually sync new endpoints to global CLAUDE.md"
fi

# --- 5. Check GitHub for new thebardchat repos ---
if command -v gh &>/dev/null; then
    CURRENT_REPOS=$(grep -oP '`[a-zA-Z0-9_-]+`' "$GLOBAL_MD" | tr -d '`' | sort -u)

    GH_REPOS=$(gh repo list "$GITHUB_ORG" --limit 100 --json name --jq '.[].name' 2>/dev/null | sort -u || true)

    if [[ -n "$GH_REPOS" ]]; then
        NEW_REPOS=$(comm -23 <(echo "$GH_REPOS") <(echo "$CURRENT_REPOS") 2>/dev/null || true)
        if [[ -n "$NEW_REPOS" ]]; then
            log "New repos found in $GITHUB_ORG:"
            echo "$NEW_REPOS" | while read -r repo; do
                log "  - $repo"
            done
            log "ACTION NEEDED: Add new repos to ecosystem tables in both CLAUDE.md files"
        else
            log "No new repos found"
        fi
    else
        log "WARN: Could not fetch repo list from GitHub (gh cli may not be authed)"
    fi
elif command -v curl &>/dev/null; then
    # Fallback: use GitHub API directly
    GH_REPOS=$(curl -s "https://api.github.com/users/$GITHUB_ORG/repos?per_page=100&sort=created&direction=desc" \
        | grep -oP '"name"\s*:\s*"\K[^"]+' | sort -u 2>/dev/null || true)

    if [[ -n "$GH_REPOS" ]]; then
        CURRENT_REPOS=$(grep -oP '`[a-zA-Z0-9_-]+`' "$GLOBAL_MD" | tr -d '`' | sort -u)
        NEW_REPOS=$(comm -23 <(echo "$GH_REPOS") <(echo "$CURRENT_REPOS") 2>/dev/null || true)
        if [[ -n "$NEW_REPOS" ]]; then
            log "New repos found in $GITHUB_ORG:"
            echo "$NEW_REPOS" | while read -r repo; do
                log "  - $repo"
            done
            log "ACTION NEEDED: Add new repos to ecosystem tables in both CLAUDE.md files"
        else
            log "No new repos found"
        fi
    else
        log "WARN: GitHub API call failed"
    fi
else
    log "WARN: Neither gh nor curl available — skipping repo check"
fi

# --- 6. Sync global → repo if global is newer ---
GLOBAL_MTIME=$(stat -c %Y "$GLOBAL_MD" 2>/dev/null || stat -f %m "$GLOBAL_MD" 2>/dev/null)
REPO_MTIME=$(stat -c %Y "$REPO_MD" 2>/dev/null || stat -f %m "$REPO_MD" 2>/dev/null)

if [[ "$GLOBAL_MTIME" -gt "$REPO_MTIME" ]]; then
    log "Global CLAUDE.md is newer than repo — check for updates to propagate"
fi

# --- 7. Commit and push if repo CLAUDE.md changed ---
cd "$REPO_DIR"
if [[ -n $(git diff --name-only "$REPO_MD" 2>/dev/null) ]]; then
    git add "$REPO_MD"
    git commit -m "chore(claude): daily sync CLAUDE.md — $(date '+%Y-%m-%d')"
    git push origin main 2>/dev/null && log "Pushed CLAUDE.md updates" || log "WARN: git push failed"
    CHANGES_MADE=true
fi

if [[ "$CHANGES_MADE" = false ]]; then
    log "No changes needed — everything in sync"
fi

# --- 8. Propagate global CLAUDE.md to all ecosystem repos ---
DEPLOY_SCRIPT="$(dirname "$0")/deploy-global-claude-md.sh"
if [[ -x "$DEPLOY_SCRIPT" ]]; then
    log "Running global CLAUDE.md deploy to all repos..."
    "$DEPLOY_SCRIPT" "$GLOBAL_MD" >> "$LOG_FILE" 2>&1 || log "WARN: Deploy script had errors — check log"
else
    log "WARN: Deploy script not found or not executable at $DEPLOY_SCRIPT"
fi

log "=== Daily CLAUDE.md sync complete ==="
