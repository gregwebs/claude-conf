---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

# Overview

The following is based off of mattpocock:implement and adds:
* a thorough planning phase at the beginning
* a commit with Change Record at the end
* agent delegation for cost control

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

Commit your work. Point to the issue in your commit if there is a real issue tracker or committed files for issues.

Record a **Change Record**. **How** depends on your capabilities and configuration.

* **Pull Request** - If you are in charge of sending Pull Requests, place the Change Record information there.
* No PR, but have an issue tracker configured:
  - **Local files** - append a **Change Record** section to the file
  - **Real issue tracker** - add the Change Record as a comment on the issue
* No PR, No issue tracker configured:
  - If there is a local location for emphemeral documents such as ./docs/change, write to a markdown file there
  - Otherwise, just write to the chat output

## Change Record Contents

Change Record documentation is
* ephemeral- describing a moment in time- it will not be updated
* more verbose than normal documentation that must be kept up to date

Avoid including information that is already in the issue/ticket (the spec) if there is a real issue tracker or committed files for issues.
We should include information useful for implementing furture related issues/tickets, particularly if this issue/ticket has a parent issue and follow-on work. This includes:
* Technical design choices
* A high level summary of changes
* A lower level summary of changes done by pointing to the places in code that were changed and mostly letting the code speak for itself.
* Checklist items performed
* Verifications performed
