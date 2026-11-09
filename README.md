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

Normal permission prompts still apply. Ask "how do I…" when you do want instructions.

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
