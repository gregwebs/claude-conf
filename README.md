AI configuration to produce high quality code.

## Goal

* Increase Agent code quality (fewer defects, stronger code base)
* Decrease user overview

Downsides
* It takes AI more time to complete its task
* Higher cost to initially complete a feature
  * For a non-prototype you will save costs due to
    * Fewer defects
    * A more agile code base

These are achieved by:
* outlining a workflow that emphasizes specing, planning, testing, verification, and architecture/design
* having a separate agent review at every stage

Requirements from you
* You have to get deeply involved with the planning stage
* Spend effort on engineering discipline



As code quality increases, the agent can do more hands off work for you.
The goal is to allow the agents to do as much work for you as you are comfortable with.
This configuration pushes things towards a large investment in alignment via grill-with-docs (give this a try, its amazing!) and then optional involvement after that point.
Pull Requests are created that you approve and merge- how closely you review them is up to you.

## Model selection

`.claude/settings.local.json` selects the `opusplan` model alias. The
permission `defaultMode` is separately set to `plan`; it requires explicit
approval to move between planning and implementation. Opus Plan mode is cost
effective because it switches between Opus for planning and Sonnet for
implementation.

The workflows and configuration here do not otherwise help with managing which model you use.

## Implementation

These files are designed to be generic with respect to programming language and project.
Most of what exists in AGENTS.md is gradually moving into skills because they are composeable.

### Base

This relies heavily on mattpocock/skills.

```
npx skills@latest add mattpocock/skills
```

These skills should be installed to your home directory.
That makes it easy to adjust the skills by inheriting them.
This repo does just that.
If you install mattpocock/skills local to your project then you will need to rename the skills from this repo that are overriding mattpocock/skills.

### Instruction ownership and provenance

```text
README.md (setup and maintenance)
             |
             v
AGENTS.md (repository policy and Change Record)
             |
             +--> shared skills (workflow behavior)
             +--> Claude/Codex adapters (platform configuration + pointer)
```

Skills that copy or behaviorally adapt upstream sections declare
`metadata.inlined-from`: an absolute or `~/` upstream `SKILL.md`, exact parent
heading, scope SHA-256, and source/local heading pairs. Context pointers,
delegation, and locally owned replacements are not inlining.

Run `./scripts/check-skill-inlines.sh` to validate all tracked records, or pass
specific `SKILL.md` paths for fixtures. On drift, review the named upstream
scope and local components, port or intentionally decline the behavior, then
refresh the digest. Parent-scope hashes also detect inserted sibling sections;
never refresh a digest merely to silence the checker.


### CLAUDE.md vs AGENTS.md

CLAUDE.md has @AGENTS.md at the top- that will include the contents of AGENTS.md into CLAUDE.md


## Workflow

Workflows are started by you, normally with the skills:

* /grill-with-docs (new feature)
* /diagnosing-bugs (fix a bug)
* /improve-codebase-architecture (cleanup your slop)
* /wayfinder (large amount of work)

Work discussed is then converted to a spec by you or the agent

* /to-spec

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

Note that in Codex skills cannot allow list tools- you need to add things allowed by the skill to the permission rules.

### Repository command interface

The stable entry points for GitHub work are `./scripts/gh-app.sh` and
`./scripts/check-ci-runs.sh`. Their bundled implementations are internal and
must not be invoked directly. Smoke-test the public interface with:

```text
workflow skills
      |
      v
./scripts/{gh-app,check-ci-runs}.sh
      |
      v
bundled skill implementations
```

```sh
./test/repository-interface.sh
```

For local validation, run:

```sh
./test/repository-interface.sh
./scripts/check-skill-inlines.sh
git diff --check
```

The contract needs `jq`, Bash, OpenSSL, and the installed skills named by
provenance. ShellCheck and optional skill validation need separately installed
tools; report unavailable tools rather than treating CI as coverage.
