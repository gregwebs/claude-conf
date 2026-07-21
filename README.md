AI configuration files to help produce high quality code.

## Goal

The main goal is to increase quality by
* outlining a workflow that emphasizes specing, planning, testing, and verification
* having a separate agent review every stage

The .claude/settings.local.json sets the default mode to plan.
Plan mode is cost effective because it switches betweeen Opus for planning and Sonnet for implementation.
This will require an explicit approval to move between planning and implementing.

The workflows and configuration here do not otherwise help with managing which model you use.

## Implementation

This relies heavily on mattpocock/skills.

```
npx skills@latest add mattpocock/skills
```

These files are designed to be generic with respect to programming language and project.
Most of this is gradually moving into skills because skills are composeable.


## CLAUDE.md vs AGENTS.md

CLAUDE.md has @AGENTS.md at the top- that will include the contents of AGENTS.md into CLAUDE.md

If you are all in on Claude just use AGENTS.md as your CLAUDE.md


## Your workflow

See AGENTS.md for the workflows. They normally start with the skills

* grill-with-docs
* implement
* improve-codebase-architecture
* diagnosing-bugs
* to-tickets (followed by implement)

The goal is to allow the agents to do as much work for you as you are comfortable with.
This configuration pushes things towards a large investment in alignment via grill-with-docs (give this a try, its amazing!) and then optional involvement after that.
Using plan mode will provide a point before implementation that you can review.
Pull Requests are created that you can approve and merge.


## Engineering discipline

The key to letting agents do more work for you is increasing the engineering discipline.
Agents are perfectly happy to implement linting, ci, e2e tests, etc *if you direct them to*.
The /implement skill directs the agent to use /tdd.
But the rest is largely project specific and is up to you to specify in your README.md, AGENTS.md, and CODING_STANDARDS.md.

Depending on the project, it can be expensive to have an agent work with e2e tests.
It is usually best to focus on other forms of quality assurance to catch most issues and to use e2e as a lighter final layer.

## Security

I created a separate user on my computer for AI- that uses the Unix security model.
On top of that I use the sandbox feature.
Allowing operations in the sandbox is a lot of work. You might consider using a VM or container with network restrictions instead.

### Github

If you are going to give the agent autonomy to interact with Github, it is better that it doesn't actually appear to be you and that permissions are restricted as much as possible.
If you use the Claude Github app, the interaction will appear to be directly from you and you cannot alter the permissions, only the repos that it has access to.

There is a skill /github-app in this repo to help the agent authenticate as Github application rather than as you.
This will not work on Claude Code for the Web (cloud) because they block Github requests- you would need to use the Claude Github app there to send a PR or teleport it back to your local Claude first.

### Github Actions CI

There is a /github-actions-ci skill for the purpose of not asking for permission to interact with github actions.
