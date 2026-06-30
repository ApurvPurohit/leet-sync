<div align="center">

# leet-sync

I got tired of the context-switching overhead between browser, IDE, and git while solving LeetCode problems. So I built **leet-sync** - a utility that wires everything together. One hotkey fetches the problem I'm looking at in Google Chrome, drops the C++ template into the right folder, opens it in VS Code, and pushes to GitHub when I get an AC. Nothing else to think about.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)]()
[![Language](https://img.shields.io/badge/lang-C++-f34b7d.svg)]()
[![skhd](https://img.shields.io/badge/hotkey-skhd-green.svg)](https://github.com/koekeishiya/skhd)

</div>

---

## Overview

One hotkey (`Cmd+Shift+L`) from any LeetCode problem page in Chrome:
1. Fetches the problem metadata and C++ template from LeetCode's GraphQL API
2. Creates the solution file at the correct path with proper extension markers
3. Opens it in VS Code, ready to code

When a submission gets accepted, a background daemon picks it up and pushes it here. Wrong answers and TLEs don't get committed.

---

## Architecture

```mermaid
flowchart LR
    Chrome["Chrome\n(LeetCode problem page)"]
    Script["leetcode-open.sh"]
    API["LeetCode GraphQL API"]
    VSCode["VS Code\n(Test → Submit)"]
    Daemon["autopush daemon"]
    GitHub["GitHub"]

    Chrome -- "Cmd+Shift+L\n(via skhd)" --> Script
    Script -- "fetch problem + template" --> API
    API --> Script
    Script -- "create file, open editor" --> VSCode
    VSCode -- "Accepted → .accepted marker" --> Daemon
    Daemon -- "git commit + push" --> GitHub
```

---

## Repository Structure

```
leet-sync/
├── scripts/
│   ├── setup.sh               — one-command install and configuration
│   ├── leetcode-open.sh       — Chrome → LeetCode API → VS Code bridge
│   └── autopush.sh            — background daemon: commit + push on accepted
│
├── config/
│   ├── vscode/settings.json   — editor settings (no autocomplete, no diagnostics)
│   ├── launchd/               — macOS Launch Agent plist for autopush
│   └── skhdrc                 — global hotkey binding
│
├── solutions/                  — {topic}/{difficulty}/{id}.{name}.cpp
│   ├── array/
│   │   ├── easy/
│   │   └── medium/
│   ├── linked-list/
│   │   └── medium/
│   └── math/
│       └── easy/
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## Solution File Format

Each file includes the markers required by the VS Code LeetCode extension for in-editor test and submit:

```cpp
/*
 * @lc app=leetcode id=61 lang=cpp
 *
 * [61] Rotate List
 */

// @lc code=start
class Solution {
public:
    ListNode* rotateRight(ListNode* head, int k) {

    }
};
// @lc code=end
```

---

## Requirements

| Dependency | Purpose | Install |
|:-----------|:--------|:--------|
| macOS 13+ | Launch Agents, AppleScript | — |
| [Homebrew](https://brew.sh) | Package manager | [brew.sh](https://brew.sh) |
| [VS Code](https://code.visualstudio.com) | Editor | `brew install --cask visual-studio-code` |
| [Google Chrome](https://www.google.com/chrome/) | Browser integration | — |
| [GitHub CLI](https://cli.github.com) | Auth and repo management | `brew install gh` |
| [skhd](https://github.com/koekeishiya/skhd) | Global hotkey daemon | `brew install koekeishiya/formulae/skhd` |
| [JetBrains Mono](https://www.jetbrains.com/lp/mono/) | Editor font | `brew install --cask font-jetbrains-mono` |
| Python 3 | API response parsing | Pre-installed on macOS |

---

## Installation

```bash
git clone https://github.com/ApurvPurohit/leet-sync.git /Volumes/workplace/LeetCode
cd /Volumes/workplace/LeetCode
./scripts/setup.sh
```

The setup script handles dependency installation, service registration, and editor configuration.

After running setup:

1. **Grant skhd accessibility access** — System Settings → Privacy & Security → Accessibility → add `/opt/homebrew/bin/skhd`
2. **Sign into the LeetCode extension** — VS Code → LeetCode sidebar → Cookie login
3. **Authenticate GitHub** — `gh auth login`
4. **Patch the LeetCode extension** — the autopush daemon needs to know when a submission is accepted. Apply this one-line patch to the extension's submit handler:

```bash
# Find the extension's submit.js
SUBMIT_JS=~/.vscode/extensions/leetcode.vscode-leetcode-*/out/src/commands/submit.js
```

In that file, after the line:
```js
const result = yield leetCodeExecutor_1.leetCodeExecutor.submitSolution(filePath);
leetCodeSubmissionProvider_1.leetCodeSubmissionProvider.show(result);
```

Add:
```js
if (result && result.indexOf("Accepted") !== -1) {
    const fs = require("fs");
    fs.writeFileSync("/Volumes/workplace/LeetCode/.accepted", filePath + "\n", { flag: "w" });
}
```

This writes a `.accepted` marker file that the autopush daemon watches for. Without this patch, nothing gets pushed.

---

## Usage

1. Open any problem on `leetcode.com` in Chrome
2. Press `Cmd+Shift+L`
3. Write your solution in VS Code
4. Click Test → Click Submit
5. On acceptance, the solution is committed and pushed automatically

Re-opening a previously solved problem navigates to the existing file — edit and resubmit to overwrite.

---

## Services

Two macOS Launch Agents run in the background. Both start on login and restart if they crash.

| Service | Purpose |
|---------|---------|
| `com.koekeishiya.skhd` | Listens for the global hotkey |
| `com.leetcode.autopush` | Commits and pushes only when a solution is accepted |

```bash
# status
launchctl list | grep -E "leetcode|skhd"

# restart autopush
launchctl unload ~/Library/LaunchAgents/com.leetcode.autopush.plist
launchctl load ~/Library/LaunchAgents/com.leetcode.autopush.plist

# restart skhd
skhd --restart-service

# logs
tail -f /tmp/leetcode-autopush.log
```

---

## Configuration

**Hotkey** — edit `config/skhdrc`, then `skhd --restart-service`

**Language** — update `leetcode.defaultLanguage` in `config/vscode/settings.json` and the language filter in `scripts/leetcode-open.sh`

**Repository path** — grep for `/Volumes/workplace/LeetCode` across the repo and update all 6 occurrences (both scripts, plist, skhdrc, VS Code settings, and the extension patch in setup.sh)

---

## Editor Configuration

The workspace is configured for distraction-free problem solving:

- All autocomplete, suggestions, and inline hints disabled
- C/C++ IntelliSense and error diagnostics turned off (LeetCode templates are incomplete by design — includes are missing, so diagnostics are noise)
- JetBrains Mono 15px, light theme, no minimap, no status bar

---

## Commit Format

```
solve: 61.rotate_list
solve: 1.two_sum, 9.palindrome_number
```

---

## License

[MIT](LICENSE)
