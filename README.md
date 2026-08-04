AI configuration to produce high quality code.

## Goal

* Increase Agent code quality (fewer defects, stronger code base)
* Decrease user overview

These are achieved by:
* outlining a workflow that emphasizes specing, planning, testing, verification, and architecture/design
* having a separate agent review at every stage

Requirements from you
* Deeply involved with the planning stage
* Spend effort on engineering discipline

Downsides
* It takes AI more time to complete its task
* Higher cost to initially complete a feature
  * For a non-prototype you will save costs due to
    * Fewer defects
    * A more agile code base

As code quality increases, the agent can do more hands off work for you.
This configuration pushes you towards a large investment in alignment via /grilling and then optional involvement after that point.
If configured and allowed, the agent can send Pull Requests, and you can decide how closesly to review them.

## Docs

See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to test changes to this repo.

## CLAUDE.md vs AGENTS.md

CLAUDE.md has @AGENTS.md at the top- that will include the contents of AGENTS.md into CLAUDE.md

## Implementation

These files are designed to be generic with respect to programming language and project.
The implementation is in the skills, which are designed to be generic.
You customize things for your repo by editing
* AGENTS.md
* README.md and other docs used by the agent, suggested:
  * CODING_STANDARDS.md (for writing and reviewing code)
  * CONTRIBUTING.md (for how to run and test the project)
  * USAGE.md - if you have a public interface to document

### Installing

This relies heavily on mattpocock/skills.

```
npx skills@latest add mattpocock/skills
```

You can install these skills to your home directory (~/.agents/skills).
However, to override those skills with ones from this repo with the same name (/grilling, /implement),
you will need to install to a different location (I suggest cloning the repo).
Then you can symlink from ~/.agents/skills to mattpocock skills and/or skills in this repo.

Alternatively you can install/override skills in an individual project.

The skils in this repo are in [.agents/skills](.agents/skills). /grilling is very experimental.

## Workflow

Workflows are started by you, normally with:

* /grill-with-docs (new feature)
* /diagnosing-bugs (fix a bug)
* /improve-codebase-architecture (cleanup your slop)
* /wayfinder (large amount of work)
* a conversation without explicit skill invocation

Work discussed is then converted to a spec by you or the agent

* /to-spec

After a spec is generated, it can be broken down into slices and published with

* /to-tickets

Then implemented with

* /implement

### Differences

The main difference between this repo and using mattpocock/skills directly is

#### Implement with a plan

The override of /implement adds the concept of an Implementation Plan. The spec created by mattpocock/skills is intentionally not very detailed since details can change.
An Implementation Plan is detailed, and is generated at the start of the implementation. This can be done in plan mode by a smarter agent (Opus/Fable).
After the plan is approved a more efficient agent (Sonnet) can take over.

### Model selection

An `implementer` agent is included that actually writes the code.
This agent uses Sonnet (with Claude).
A `planner` agent uses Opus.

If you want another intervention point in the workflow, use planning.
With permission `defaultMode` is separately set to `plan` and 
the `opusplan` model alias- this can be done in  `.claude/settings.local.json`.
This requires explicit approval to move between planning and implementation.
Opus Plan mode helps ensure cost effective module usage by switching between Opus for planning and Sonnet for
implementation. This workflow already does that via subagents.

#### Agent review at every step

A separate agent provides an adversarial review of both the plan and the code.

#### Artifact-based handoffs

Planning, implementation, and review agents start with fresh context instead of
inheriting the main conversation. The orchestrator carries decisions across
those seams with task-scoped Markdown artifacts in a temporary directory
outside the repository:

```text
task-brief.md
      |
      v
implementation-plan.md <-> plan-review.md
      |
      v
working tree + implementation-result.md
      |
      v
code-review.md
```

This keeps each agent's interface limited to the work product and source
references it needs. The artifacts are workflow scratch state, not lasting
technical documentation, and are never committed. The `/implement` skill owns
the artifact names and operational handoff rules.


#### Agent sends a Pull Request

Commit.
PR, and check on CI- this is Github specific and conditional on setting up access and instructing in AGENTS.md/CLAUDE.md to send a PR.


## Engineering discipline

The key to letting agents do more work for you is increasing the engineering discipline.
Agents are perfectly happy to implement linting, ci, e2e tests, etc *if you direct them to*.
The /implement skill directs the agent to use /tdd.
But the rest is largely project specific and is up to you to specify in your documentation and to spend time implementing these engineering practices.

## Security

We want to let the agent do safe operations without prompting us- prompt fatigue creates security risks.
The agent should be operating in an isolated sandbox.
The agent should be a separate user on your computer- either a separate Unix user or a container/VM user.
Have the agent write code (scripts) for common workflows and commit those.

### Github

If you are going to give the agent autonomy to interact with Github, it is better that it doesn't actually appear to be you and that permissions are restricted as much as possible.
If you use the Claude Github app, the interaction will appear to be directly from you and you cannot alter the permissions, only the repos that it has access to.

There is a skill /github-app in this repo to help the agent authenticate as Github application rather than as you.
This will not work on Claude Code for the Web (cloud) because they block Github requests- you would need to use the Claude Github app there to send a PR or teleport it back to your local Claude first.

### Github Actions CI

There is a /github-actions-ci skill for the purpose of not asking for permission to interact with github actions.
Its check-run helper is bundled and allow-listed with `${CLAUDE_SKILL_DIR}`, so
the repository being checked does not need its own CI wrapper script.

Note that in Codex skills cannot allow list tools- you need to add things allowed by the skill to the permission rules.
