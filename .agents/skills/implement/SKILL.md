---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

# Overview

Implement a change with planning and reviewing.

# Agent Delegation

Orchestrate subagents to minimize context and cost.
The `planner` subagent is smarter and more costly and produces the design.
The `implementer` subagent implements the plan and is designed to lower costs.
Artifacts are passed between agents with the goal that agents start with a summary of all useful information from other agents. Re-exploration should be minimized, although it is needed for independent reviews and for the implementer to go into further detail.

If the required planner or implementer delegation is unavailable, stop after
planning and ask the user for an implementer/model handoff (the /handoff skill may be available). Do not execute the plan inline on the planning model.

Use artifacts at every delegation seam. At the start of the workflow, create a
task-scoped temporary directory outside the repository. Do not commit its
contents. The orchestrator, not a read-only delegate, persists each returned
artifact. Pass absolute artifact paths between agents:

- `task-brief.md`: the user request, settled decisions, and source references
- `implementation-plan.md`: the current plan; executable only after review
- `plan-review.md`: adversarial plan findings
- `implementation-result.md`: changed files and verification performed
- `code-review.md`: implementation review findings
- `code-review-followup.md`: implementation review followup findings
- `verifications.md`: verifications to be performed

Start every planner, reviewer, and implementer delegation without inherited
conversation history. In Codex use `fork_turns="none"`; use the equivalent
empty-context option on other platforms. Give the delegate only its requested
action and the artifact or source paths it needs. Do not paste the conversation
transcript into the delegation prompt.

# Flow

## Phase 1 - A good plan

Create `task-brief.md`, then delegate planning to a fresh `planner` subagent
using `/implementation-plan`. Give it the task brief path and any durable source
paths. Persist its output as `implementation-plan.md`.

## Phase 2 - Plan execution

Delegate to a fresh `implementer` sub-agent with only
* `task-brief.md`
* `implementation-plan.md`

### implementer sub-agent

Read the `task-brief.md` and `implementation-plan.md` paths. Do not redesign the plan.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Don't document *what* code does. Write new code to make what it self-documenting. For example, extract code to a function with a descriptive name.
When appropriate document *why* code does what it does due to a requirement or in preference to an alternative.

STOP executing immediately when
* Plan has critical gaps
* You don't understand an instruction
* Verification fails repeatedly

Persist a final report as `implementation-result.md`.

Separate out any verifications from `implementation-plan.md` and `implementation-result.md` as `verifications.md`.

## Phase 3 - Review

Perform `/code-review-with-followup` using these files:
* `task-brief.md`
* `implementation-plan.md`
* `implementation-result.md`
* `verifications.md`

During the review, add any new requested verifications to `verifications.md`.
Update `implementation-result.md` according to changes made from the code review.

## Phase 3 - Verification

Delegate to a fresh `implementer` sub-agent to perform required verifications. They should have access to
* `task-brief.md`
* `implementation-plan.md`
* `implementation-result.md`
* `verifications.md`

### implementer sub-agent

Verify manually that the changes work as expected in an e2e end user setting.
Test edge cases and failure modes in addition to the happy path.
Look at `verifications.md` for verification tests to perform.

Consider whether any manual verification steps can and should be added as automated tests.
Write these additional tests.

Don't make any changes to data that cannot be undone.
If possible work against a backup of data or seed data.

## Phase 4 - Completion

Do the following if your instructions authorize/direct it and the capability is available.
* Commit your work. Reference relevant issues/tickets in your commit message.
* Generate a PR
* Watch for CI success

Use the `/document-changes` skill to record your changes.
