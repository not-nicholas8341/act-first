# act-first

A Claude Code plugin that makes Claude **do the task** instead of telling you how.

**The problem:** you ask Claude to "connect to GitHub" and get a list of steps to do yourself.
It only does the work after you say "no, you do it".

**The fix:** act-first does two things.
1. **Sets the rule.** At session start (and after context compaction), it tells Claude to do
   anything it has the tools for, and to hand you only what truly needs you: logins,
   passwords, 2FA, payments.
2. **Enforces it.** If Claude's final reply still says things like "you can run…" or
   "follow these steps", a Stop hook sends it back once to do the work itself.

Normal permission prompts still apply. Want instructions instead? Ask "how do I…" or
"explain…" and the hook lets them through. A single `! command` hand-off (like a login)
is allowed too.

The check costs about 0.2s per reply on Windows, less on macOS/Linux, and adds no tokens.

## Install

In Claude Code:

```
/plugin marketplace add YOUR_GITHUB_USERNAME/act-first
/plugin install act-first@act-first
```

Restart Claude Code. Turn it off anytime with `/plugin` → disable act-first.

Requires bash (built in on macOS/Linux; Claude Code on Windows uses Git Bash).

## Test

```
bash tests/test_stop.sh
```

Live check in a real session (uses a little API usage). The debug log should show
`Hooks: Stop ... status 2`, then `status 0`:

```
claude -p --model haiku --plugin-dir . --debug-file debug.log "Write exactly: You can run npm install."
```
