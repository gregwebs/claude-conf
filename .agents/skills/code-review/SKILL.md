---
name: code-review
description: Perform a Code Review. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X".
---

# /code-review - project wrapper

This project shadows the personal `code-review` skill so that:
* a specific persona is used as a subagent
* claude invokes codex if it is available
* an adversarial review is peformed for initial code review for initial code review

## Delegate

Read `~/.agents/skills/code-review/SKILL.md`, the base skill's canonical path.
Code review should closely follow the procedures outlined here.

If that base file does not exist on this machine, stop and tell the user the
personal `code-review` skill is missing. This wrapper intentionally depends on
the personal skill instead of vendoring its process.

## Adeversarial Review

The first code review should be adversarial. Follow up reviews of changes made based off of the adversarial review should be non-adversarial.

## Agent Code Review

* Use a subagent for code review.
* Use the engineering-lead persona defined in `.claude/agents/engineering-lead.md`.
* A different agent persona can be used if specified when the skill is invoked.

## Claud Prefers Codex

When running from Claude Code, if the codex plugin is installed, use Codex. Do not substitute Claude's own review.
However, do not invoke Codex for trivial documentation or formatting-only changes.

If the codex plugin is installed but not working (probably needs re-authentication), stop and ask the user if they want to fix this.

Invoke Codex via:

```
node $HOME/.claude/plugins/cache/openai-codex/codex/1.0.5/scripts/codex-companion.mjs task --cwd "$(pwd)"
```

If the code is already committed, add: `--base main`

#### Plan/spec review

Pass the plan/spec as `--prompt-file`, starting with "Review the following plan/spec".
Use instructions from the `codex:adversarial-review` skill (or `codex:review` for follow-ups).
If the review suggests a significantly different approach, ask the user to choose between them and recommend one.

#### Code review

Pass the plan/spec for the changes as `--prompt-file`.
If there is only a conversation to go off of, summarize it to a spec first with the /to-spec skill.
Use instructions from the `codex:adversarial-review` skill (or `codex:review` for follow-ups).
Only ask the user to resolve review issues if resolution would alter the plan/spec.

### Fallback: subagent

If Codex is not available, use a separate Claude subagent.
