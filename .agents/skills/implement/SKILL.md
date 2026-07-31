---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

# Overview

This repository owns this workflow locally. It adds a detailed planning phase,
independent review, a user approval gate, and a Change Record.

# Agent Delegation

If the required planner or implementer delegation is unavailable, stop after
planning and ask the user for an implementer/model handoff. Do not execute the
plan inline on the planning model.

Use artifacts at every delegation seam. At the start of the workflow, create a
task-scoped temporary directory outside the repository. Do not commit its
contents. The orchestrator, not a read-only delegate, persists each returned
artifact. Pass absolute artifact paths between agents:

- `task-brief.md`: the user request, settled decisions, and source references
- `implementation-plan.md`: the current plan; executable only after review
- `plan-review.md`: adversarial plan findings
- `implementation-result.md`: changed files and verification performed
- `code-review.md`: implementation review findings

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

Delegate an independent review to a fresh reviewer with only the task brief and
plan paths. Review in Spec → Architecture → Quality order and persist the
findings as `plan-review.md`. Give a fresh planner those three artifact paths,
then replace `implementation-plan.md` with the revised output.

## Phase 2 - Plan execution

Delegate to a fresh `implementer` with only the `task-brief.md` and
`implementation-plan.md` paths. Do not redesign the independently reviewed
plan. Persist the implementer's final report as `implementation-result.md`.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Don't document *what* code does. Write new code to make what it does self-documenting.
When appropriate document *why* code does what it does due to a requirement or in preference to an alternative.

Once done, delegate `/code-review` to a fresh reviewer with the task brief,
plan, implementation result, and fixed-point reference. Persist its findings as
`code-review.md`. If changes are required, give a fresh implementer only the
task brief, plan, and code review paths, then run a non-adversarial follow-up
review from artifacts.

## Phase 3 - Verification

Verify manually that the changes work as expected in an e2e end user setting.
Test edge cases and failure modes in addition to the happy path.
Look at the **Implementation Plan** for verification tests to perform.

Consider whether any manual verification steps can and should be added as automated tests.
Don't make any changes to data that cannot be undone.
If possible work against a backup of data or seed data.

## Phase 4 - Completion

Do the following if your instructions authorize/direct it and the capability is available.
* Commit your work. Reference relevant issues/tickets in your commit message.
* Generate a PR
* Watch for CI success

Use the `/document-changes` skill to record your changes.
