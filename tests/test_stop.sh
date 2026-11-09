#!/usr/bin/env bash
# Run: bash tests/test_stop.sh   (2 = sent back to do the work, 0 = allowed to stop)
hook="$(dirname "$0")/../hooks/stop.sh"; fail=0
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
printf '%s\n' '{"type":"user","message":{"role":"user","content":"how do I connect to github?"}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"ok"}]}}' > "$tmp/howto.jsonl"
printf '%s\n' '{"type":"user","message":{"role":"user","content":"connect this to github"}}' \
  '{"type":"user","isMeta":true,"message":{"role":"user","content":"Caveat: explain nothing"}}' \
  '{"type":"user","message":{"role":"user","content":"<local-command-stdout>instructions</local-command-stdout>"}}' > "$tmp/doit.jsonl"

check() { printf '%s' "$2" | bash "$hook" 2>/dev/null; got=$?
  [ "$got" = "$1" ] && echo "ok   $3" || { echo "FAIL $3 (want $1, got $got)"; fail=1; }; }
m() { printf '{"stop_hook_active":%s,"transcript_path":"%s","last_assistant_message":"%s"}' "${3:-false}" "$2" "$1"; }

check 2 "$(m 'To connect, you can run `git remote add origin ...`' "$tmp/doit.jsonl")" "hands off a command"
check 2 "$(m 'Follow these steps:\n1. Open settings' "$tmp/doit.jsonl")" "lists steps"
check 2 "$(m 'Sure:\n1. Install gh\n2. Run `gh auth login`\n3. Run `git push`' "$tmp/doit.jsonl")" "login buried in a step list"
check 2 "$(m 'Paste this in your terminal: npm i' "$tmp/doit.jsonl")" "in your terminal"
check 2 "$(m 'Saved \"config.json\". Next, you should run npm test' "$tmp/doit.jsonl")" "parses past escaped quotes"
check 0 "$(m 'Done. Repo created and pushed.' "$tmp/doit.jsonl")" "did the work"
check 0 "$(m 'Installed gh. You need to run `! gh auth login` to sign in, then I will push.' "$tmp/doit.jsonl")" "single ! hand-off allowed"
check 0 "$(m 'Follow these steps:\n1. Install gh' "$tmp/howto.jsonl")" "user asked how-to"
check 0 "$(m 'You can run npm install' "$tmp/doit.jsonl" true)" "already sent back once"
check 0 '{}' "missing message"
if command -v cygpath >/dev/null; then  # Windows: JSON carries C:\\Users\\... paths
  win=$(cygpath -w "$tmp/howto.jsonl" | sed 's/\\/\\\\/g')
  check 0 "$(m 'You can run ssh-keygen' "$win")" "windows transcript path"
fi
exit $fail
