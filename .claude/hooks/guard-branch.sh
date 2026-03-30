#!/bin/bash
# Guard against editing files on protected branches.
# Blocks Edit/Write tools with exit 2 when on mixtape-develop or main.
# Claude Code will surface the stderr message — the agent should then
# create a working branch via Bash before retrying the edit.

REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
BRANCH=$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)

case "$BRANCH" in
  mixtape-develop|main)
    DATE=$(date +%Y%m%d)
    cat >&2 <<EOF
BLOCKED: You are on protected branch '$BRANCH'.
Create a working branch before editing any files.

Convention: mixtape-dev-${DATE}_brief_summary
Example:    mixtape-dev-${DATE}_add_user_avatars

Steps:
  git pull origin $BRANCH
  git checkout -b mixtape-dev-${DATE}_<summary>
EOF
    exit 2
    ;;
esac

exit 0
