# act-first

A Claude Code plugin that makes Claude **do the task** instead of telling you how.

**The problem:** you ask Claude to "connect to GitHub" and get a list of steps to do yourself.
It only does the work after you say "no, you do it".

**The fix:** with act-first installed, Claude does everything it has the tools for. It only
hands you the steps it truly can't do, like a browser login or a password, and then carries on.
Normal permission prompts still apply.

## Install

In Claude Code:

```
/plugin marketplace add YOUR_GITHUB_USERNAME/act-first
/plugin install act-first@act-first
```

Restart Claude Code. Turn it off anytime with `/plugin` → disable act-first.
