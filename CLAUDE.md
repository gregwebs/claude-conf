@AGENTS.md

## Agent Review

When running from Claude Code, if the codex plugin is installed, use Codex for review as defined below.
Otherwise ask the engineering-lead agent for a review.

### Codex review

Invoke the `codex:codex-rescue` subagent in the foreground and wait for its response.

1. For plan review ask Codex to review the included plan, challenge assumptions, identify missing cases, and suggest better alternatives. Read-only.

2. For code review ask Codex to review the current git diff Read-only.
   Require findings ordered by severity with file:line references.

Address material findings, rerun tests, and request one follow-up Codex
review if the implementation changed substantially.

Do not substitute Claude's own review for these checkpoints.
Do not invoke Codex for trivial documentation or formatting-only changes.

Use the engineeering-lead instructions in .claude/agents/engineering-lead.md