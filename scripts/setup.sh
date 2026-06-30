#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

echo "Setting up leet-sync..."
echo ""

# -- Check basics --

command -v brew &>/dev/null || { echo "Need Homebrew. See https://brew.sh"; exit 1; }
command -v python3 &>/dev/null || { echo "Need python3."; exit 1; }
[ -d "/Applications/Visual Studio Code.app" ] || { echo "Need VS Code."; exit 1; }

# -- Install tools --

command -v gh &>/dev/null || brew install gh
command -v skhd &>/dev/null || brew install koekeishiya/formulae/skhd

# VS Code extension
"$CODE" --list-extensions 2>/dev/null | grep -qi leetcode || \
    "$CODE" --install-extension LeetCode.vscode-leetcode

# Font
find ~/Library/Fonts /Library/Fonts -iname "*JetBrainsMono*" 2>/dev/null | grep -q . || \
    brew install --cask font-jetbrains-mono

# -- Wire up configs --

mkdir -p "$REPO_DIR/.vscode"
cp "$REPO_DIR/config/vscode/settings.json" "$REPO_DIR/.vscode/settings.json"
cp "$REPO_DIR/config/skhdrc" "$HOME/.skhdrc"

# -- Launch Agent --

PLIST_DST="$HOME/Library/LaunchAgents/com.leetcode.autopush.plist"
launchctl unload "$PLIST_DST" 2>/dev/null || true
cp "$REPO_DIR/config/launchd/com.leetcode.autopush.plist" "$PLIST_DST"
launchctl load "$PLIST_DST"

# -- Start skhd --

skhd --stop-service 2>/dev/null || true
skhd --start-service 2>/dev/null || true

# -- VS Code in PATH --

if ! grep -q "Visual Studio Code" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo 'export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"' >> "$HOME/.zshrc"
fi

echo ""
echo "Done. Remaining manual steps:"
echo "  - Grant skhd Accessibility access (System Settings → Privacy & Security → Accessibility)"
echo "  - Sign into LeetCode extension in VS Code (Cookie method)"
echo "  - gh auth login (if not already)"
