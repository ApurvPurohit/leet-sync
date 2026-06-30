#!/bin/bash
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/opt/homebrew/bin:$PATH"

REPO="/Volumes/workplace/LeetCode"

# Get Chrome URL
URL=$(osascript -e 'tell application "Google Chrome" to return URL of active tab of front window' 2>/dev/null)
SLUG=$(echo "$URL" | sed -nE 's|.*/problems/([^/]+).*|\1|p')
[ -z "$SLUG" ] && exit 0

SNAKE_NAME=$(echo "$SLUG" | tr '-' '_')

# If file exists, just open it
EXISTING=$(find "$REPO" -name "*${SNAKE_NAME}.cpp" -not -path "*/.git/*" 2>/dev/null | head -1)
if [ -n "$EXISTING" ]; then
    code --reuse-window "$REPO" --goto "$EXISTING"
    exit 0
fi

# Fetch from LeetCode API and create file with proper markers
FILEPATH=$(curl -s 'https://leetcode.com/graphql' \
  -H 'Content-Type: application/json' \
  -d '{"query":"query{question(titleSlug:\"'"$SLUG"'\"){questionFrontendId title difficulty topicTags{slug}codeSnippets{lang code}}}"}' \
| python3 -c "
import json, os, sys
data = json.loads(sys.stdin.read())['data']['question']
qid = data['questionFrontendId']
title = data['title']
diff = data['difficulty'].lower()
tag = data['topicTags'][0]['slug']
code = next(s['code'] for s in data['codeSnippets'] if s['lang'] == 'C++')
path = '$REPO/solutions/' + tag + '/' + diff + '/' + qid + '.$SNAKE_NAME.cpp'
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, 'w') as f:
    f.write('/*\n')
    f.write(f' * @lc app=leetcode id={qid} lang=cpp\n')
    f.write(' *\n')
    f.write(f' * [{qid}] {title}\n')
    f.write(' */\n\n')
    f.write('// @lc code=start\n')
    f.write(code + '\n')
    f.write('// @lc code=end\n')
print(path)
")

[ -n "$FILEPATH" ] && code --reuse-window "$REPO" --goto "$FILEPATH"
