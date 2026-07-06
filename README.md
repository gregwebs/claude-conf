Claude configuration files for quality code.

## Goal

The main goal is to increase quality by
* outlining a workflow that emphasizes thorough planning, testing, and verification
* using an engineering-lead agent to review plans and code changes

The .claude/settings.local.json sets the default mode to plan.
If claude does not get a review from the engineering-lead agent, just ask it:

    Have the engineering-lead agent review these changes.

## Implementation

These files are designed to be generic with respect to programming language and project.
Currently you should modify them to add project specific information.
But maybe we can figure out how to layer that on top.

## CLAUDE.md vs AGENTS.md

CLAUDE.md has @AGENTS.md at the top- that will include the contents of AGENTS.md into CLAUDE.md

If you are all in on Claude just use AGENTS.md as your CLAUDE.md
