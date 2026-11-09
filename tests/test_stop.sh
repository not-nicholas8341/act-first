#!/usr/bin/env bash
# Run: bash tests/test_stop.sh   (expects exit 2 = sent back, 0 = allowed to stop)
hook="$(dirname "$0")/../hooks/stop.sh"; fail=0
check() { printf '%s' "$2" | bash "$hook" 2>/dev/null; got=$?
  [ "$got" = "$1" ] && echo "ok   $3" || { echo "FAIL $3 (want $1, got $got)"; fail=1; }; }

check 2 '{"stop_hook_active":false,"last_assistant_message":"To connect, you can run `git remote add origin ...`"}' "hands off a command"
check 2 '{"stop_hook_active":false,"last_assistant_message":"Follow these steps:\n1. Open settings"}' "lists steps"
check 0 '{"stop_hook_active":false,"last_assistant_message":"Done. Repo created and pushed."}' "did the work"
check 0 '{"stop_hook_active":false,"last_assistant_message":"Installed gh. You need to run `! gh auth login` to sign in."}' "login hand-off allowed"
check 0 '{"stop_hook_active":true,"last_assistant_message":"You can run npm install"}' "already nudged once"
check 2 '{"stop_hook_active":false,"last_assistant_message":"Saved \"config.json\". Next, you should run npm test"}' "parses past escaped quotes"
check 0 '{}' "missing message"
exit $fail
