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

# Flow

## Phase 1 - A good plan

Delegate planning for `$ARGUMENTS` to the `planner` subagent using
`/implementation-plan`. Ensure there is an independent review in Spec →
Architecture → Quality order, and that the findings are incorporated.

## Phase 2 - Plan execution

Pass the independently reviewed, Phase 1 output **verbatim** to
the `implementer` subagent. Do not redesign it.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Don't document *what* code does. Write new code to make what it does self-documenting.
When apropriate document *why* code does what it does due to a requirement or in preference to an alternative.

Once done, use `/code-review` to review the work.

## Phase 3 - Verification

Verify manually that the changes work as expected in an e2e end user setting.
Test edge cases and failure modes in addition to the happy path.
Look at the **Implementation Plan** for verification tests to peform.

Consider whether any manual verification steps can and should be added as automated tests.
Don't make any changes to data that cannot be undone.
If possible work against a backup of data or seed data.

## Phase 4 - Completion

Do the following if your instructions authorize/direct it and the capability is available.
* Commit your work
* Generate a PR
* Watch for CI success

Use the `/document-changes` skill to record your changes.
