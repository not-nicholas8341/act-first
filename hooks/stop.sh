#!/usr/bin/env bash
# Stop hook: if Claude's final reply hands the user steps it could have done itself,
# send it back once to do them. Runs every turn, so the common path uses bash
# builtins only (no grep/sed forks, which are slow on Windows).
# ponytail: phrase heuristic, not a classifier; swap for a "prompt" hook if misses
# matter more than an LLM call per turn.
# Read fd 0 directly: Claude Code's hook stdin on Windows has no /dev/stdin.
IFS= read -r -d '' in
shopt -s nocasematch

# Does the reply hand work back? Most turns exit here. Matched against the whole
# hook input: the other fields are ids and paths, which never contain these phrases.
active='"stop_hook_active" *: *true'  # already sent back once this turn -> no loops
handoff="you('ll| will)? (can|could|should|need to|have to|may want to|might want to|want to) (run|install|open|create|edit|add|go to|navigate|click|paste|type|copy|set up|configure|download|enable|update|delete|restart|execute)"
handoff+="|run (the following|this command|these commands)|follow these steps|here's how (to|you)|steps to (do|set|get|install|connect)"
handoff+="|in your terminal|open (a|your) terminal|copy and paste|go ahead and (run|install|open)|try running|(next|then|first),? run "
handoff+='|\\n *[0-9]+[.)] *\**(run|open|install|click|go to|navigate|create|type|paste|download|enable|select) '
if (( ${#in} < 4000 )); then
  [[ $in =~ $active ]] && exit 0
  [[ $in =~ $handoff ]] || exit 0
else  # bash matching is slow on long text; grep is faster there
  printf '%s' "$in" | grep -qE "$active" && exit 0
  printf '%s' "$in" | grep -qiE "$handoff" || exit 0
fi

# The sanctioned hand-off: one `! cmd` for the user (e.g. a login), no step list.
steps='\\n *[0-9]+[.)] '
[[ $in == *'`! '* && ! $in =~ $steps ]] && exit 0

# Rare path from here: user asked for instructions -> giving them is correct.
re='"transcript_path" *: *"(([^"\\]|\\.)*)"'
if [[ $in =~ $re ]]; then
  t=${BASH_REMATCH[1]//\\\\/\/}
  # last typed prompt: string content, not a tool result, not a system/meta line
  [ -f "$t" ] && grep '"role":"user","content":"[^<]' "$t" | grep -v '"isMeta":true' | tail -1 \
    | grep -qiE 'how (do|can|would|should|to) |explain|walk me through|show me how|instructions|tutorial|teach me|what are the steps|guide me' && exit 0
fi

echo "act-first: your reply hands the user steps you have the tools to do. Do them yourself now. If what's left truly needs the user (login, password, payment), name that one step as \`! command\` and stop." >&2
exit 2
