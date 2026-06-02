Claude configuration files for quality code.

## Goal

The main goal is to increase quality by
* outlining a workflow that emphasizes planning, testing, and verification
* using an engineering-lead agent to review plans and code changes

The .claude/settings.local.json sets the default mode to plan.
If claude does not get a review from the engineering-lead agent, just ask it:

    Have the engineering-lead agent review these changes.

## Implementation

These files are designed to be generic with respect to programming language and project.
Currently you should modify them to add project specific information.
But maybe we can figure out how to layer that on top.

* CLAUDE.md
* .claude/settings.local.json
* .claude/agents/engineering-lead.md