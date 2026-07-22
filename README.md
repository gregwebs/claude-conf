AI configuration files to help produce high quality code.

## Goal

The main goal is to increase quality by
* outlining a workflow that emphasizes specing, planning, testing, and verification
* having a separate agent review every stage

With quality increased, that allows the agent to do more hands off work for you.
The goal is to allow the agents to do as much work for you as you are comfortable with.
This configuration pushes things towards a large investment in alignment via grill-with-docs (give this a try, its amazing!) and then optional involvement after that point.
Pull Requests are created that you approve and merge.

The .claude/settings.local.json sets the default mode to opusplan.
(Opus) Plan mode is cost effective because it switches betweeen Opus for planning and Sonnet for implementation.
This will require an explicit approval to move between planning and implementing.

The workflows and configuration here do not otherwise help with managing which model you use.

## Implementation

These files are designed to be generic with respect to programming language and project.
Most of what exists in AGENTS.md is gradually moving into skills because skills are composeable.

### Base

This relies heavily on mattpocock/skills.

```
npx skills@latest add mattpocock/skills
```

These skills should be installed to your home directory.
That makes it easy to adjust the skills by inheriting them.
This repo does just that.
If you install mattpocock/skills local to your project then you will need to rename the skills from this repo that are overriding mattpocock/skills.


## CLAUDE.md vs AGENTS.md

CLAUDE.md has @AGENTS.md at the top- that will include the contents of AGENTS.md into CLAUDE.md


## Workflow

Workflows are started by you, normally with the skills:

* /grill-with-docs (new feature)
* /diagnosing-bugs (fix a bug)
* /improve-codebase-architecture (cleanup your slop)
* /to-spec (specify work from a conversation)
* /wayfinder (large amount of work)

After a spec is generated, it can be broken down into slices with

* /to-tickets

Then implemented with

* /implement

### Differences

The main difference between this repo and using mattpocock/skills directly is

#### Implement with a plan

The override of /implement adds the concept of an Implementation Plan. The spec created by mattpocock/skills is intentionally not very detailed since details can change.
An Implementation Plan is detailed, and is generated at the start of the implementation. This can be done in plan mode by a smarter agent (Opus/Fable).
After the plan is approved a more efficient agent (Sonnet) can take over.

#### Agent review at every step

A separate agent reviews both the plan and the code.
Reviews are adversarial. Follow up reviews are not adversarial.


## Engineering discipline

The key to letting agents do more work for you is increasing the engineering discipline.
Agents are perfectly happy to implement linting, ci, e2e tests, etc *if you direct them to*.
The /implement skill directs the agent to use /tdd.
But the rest is largely project specific and is up to you to specify in your documentation and to spend time implementing these engineering practices.

## Security

We want to let the agent do safe operations without prompting us- prompt fatigue creates security risks.
I created a separate user on my computer for AI- that uses the Unix security model.
On top of that I use the sandbox feature.
Allowing operations in the sandbox can be a lot of work. You might consider using a VM or container with network restrictions rather than the claude/codex sandbox.

### Github

If you are going to give the agent autonomy to interact with Github, it is better that it doesn't actually appear to be you and that permissions are restricted as much as possible.
If you use the Claude Github app, the interaction will appear to be directly from you and you cannot alter the permissions, only the repos that it has access to.

There is a skill /github-app in this repo to help the agent authenticate as Github application rather than as you.
This will not work on Claude Code for the Web (cloud) because they block Github requests- you would need to use the Claude Github app there to send a PR or teleport it back to your local Claude first.

### Github Actions CI

There is a /github-actions-ci skill for the purpose of not asking for permission to interact with github actions.

Note that in Codex skills cannot allow list tools- you need to add things allowed by the skill to the permission rules.
