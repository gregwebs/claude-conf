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

## Your workflow

Start by using plan mode! Use the best model you can for planning (Opus/Fable or equivalent).
For implementation, use Sonnet. For a final code review, use the best model you can. 

It is up to you how much you want to get involved- thoroughly review all changes or commit things vibe-coded.
In either case the goal is that the agent is producing the best possible output.

## Engineering discipline

The key to letting agents do more work for you is increaseing the engineering discipline.
Agents are perfectly happy to implement linting, ci, e2e tests, etc if you direct them to.

Depending on the project, it can be expensive to have an agent work with e2e tests.
It is usually best to focus on other forms of quality assurance to catch most issues and to use e2e as a lighter final layer.
If there is no e2e test written we can still ask the agent for some kind of ad-hoc verication.
