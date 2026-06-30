#!/bin/bash
# Auto-commit and push LeetCode solutions on file change
# Polls every 15 seconds — only commits if files are stable

REPO="/Volumes/workplace/LeetCode"
INTERVAL=15
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

cd "$REPO" || exit 1

while true; do
    sleep "$INTERVAL"

    # Check if there are uncommitted changes
    git -C "$REPO" diff --quiet && git -C "$REPO" diff --cached --quiet && \
    [ -z "$(git -C "$REPO" ls-files --others --exclude-standard)" ] && continue

    # Wait one more interval to confirm stable (not mid-edit)
    sleep "$INTERVAL"

    cd "$REPO" || continue
    git add -A
    git diff --cached --quiet && continue

    MSG=$(git diff --cached --name-only | grep '\.cpp$' | sed 's|.*/||;s|\.cpp$||' | paste -sd ', ' -)
    [ -z "$MSG" ] && MSG="update"
    git commit -m "solve: $MSG"
    git push
done
