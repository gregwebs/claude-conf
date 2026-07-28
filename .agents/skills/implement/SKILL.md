---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

# Overview

The following is based off of mattpocock:implement for
* agent delegation
* a thorough planning phase at the beginning
* a commit at the end

# Agent Delegation

If agent delegation is unavailable, say so and prompt the user to select the apropriate model for the phase.

# Flow

## Phase 1 - A good plan

Delegate this phase to the `planner` subagent to plan: $ARGUMENTS.

Use /implementation-plan to generate a detailed **Implementation Plan**.

## Phase 2 - Plan execution

Pass Phase 1's output **verbatim** in the delegation prompt to the
`implementer` subagent. Do not implement inline — that would run execution on the planning model.

Implement the **Implementation Plan** as written. Do not redesign it.
Ask for user approval to deviate from the plan or alter it.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

## Phase 3 - completion

Commit your work.
