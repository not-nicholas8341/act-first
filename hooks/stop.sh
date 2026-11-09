#!/usr/bin/env bash
# Stop hook: if Claude's final reply hands the user steps it could have done itself,
# send it back once to do them. ponytail: regex heuristic, not a classifier.
in=$(cat)

# Already nudged this turn -> let it stop (prevents loops).
printf '%s' "$in" | grep -qE '"stop_hook_active" *: *true' && exit 0

msg=$(printf '%s' "$in" | grep -oE '"last_assistant_message" *: *"([^"\\]|\\.)*"')
[ -z "$msg" ] && exit 0

# Legit hand-offs (logins, secrets, payments) are fine.
printf '%s' "$msg" | grep -qiE 'log ?in|sign ?in|password|2fa|two-factor|passkey|token|api key|credential|payment|credit card' && exit 0

if printf '%s' "$msg" | grep -qiE "you (can|could|should|need to|'ll need to|will need to|may want to) (run|install|open|create|edit|add|go to|navigate|click|paste|type|copy|set up|configure|download)|run the following|follow these steps|here's how (to|you)|steps to (do|set|get|install|connect)"; then
  echo "act-first: your reply tells the user to do steps you have the tools to do. Do them yourself now. If the user asked how-to, or a step truly needs them (login, password, payment), say so in one line and stop." >&2
  exit 2
fi
exit 0
