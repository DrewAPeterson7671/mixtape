#!/bin/bash
# Guard against editing files on protected branches.
# Blocks Edit/Write tools with exit 2 when the target file's repo is on a
# protected branch. Reads the file_path from the tool input JSON on stdin,
# resolves which git repo it belongs to, and checks that repo's branch.
#
# Protected branches:
#   Backend (mixtape):    mixtape-develop, main
#   Frontend (mixtapeUI): mixtape-dev, main

# Read tool input JSON from stdin and extract file_path
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  # No file_path in input — nothing to guard
  exit 0
fi

# Resolve the git repo that contains the target file
FILE_DIR=$(dirname "$FILE_PATH")
REPO_DIR=$(git -C "$FILE_DIR" rev-parse --show-toplevel 2>/dev/null)

if [ -z "$REPO_DIR" ]; then
  # Not inside a git repo — allow
  exit 0
fi

BRANCH=$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)

case "$BRANCH" in
  mixtape-develop|mixtape-dev|main)
    DATE=$(date +%Y%m%d)
    cat >&2 <<EOF
BLOCKED: File '$FILE_PATH' is in repo '$REPO_DIR'
which is on protected branch '$BRANCH'.
Create a working branch before editing any files.

Convention: ${BRANCH}-${DATE}_brief_summary
Example:    ${BRANCH}-${DATE}_add_user_avatars

Steps:
  cd $REPO_DIR
  git pull origin $BRANCH
  git checkout -b ${BRANCH}-${DATE}_<summary>
EOF
    exit 2
    ;;
esac

exit 0
