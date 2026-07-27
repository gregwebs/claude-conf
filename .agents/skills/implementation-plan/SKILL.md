---
name: implementation-plan
description: "Create a detailed Implementation Plan for a ticket or spec, corresponding to a single Pull Request."
---

# /implementation-plan

Create a detailed Implementation Plan for a ticket or spec.

Use /plan mode and a thinking model for the plan creation.

## Prerequisites

If there is already an **Implementation Plan** that satisfies the "What to include" criteria below, use it rather than creating a new one.

If there is already a spec, that is your starting point.
If not, suggest using /grill-me-with-docs to align on changes and then /to-spec to first create a spec.

An Implementation Plan should be a single work item.
Use /breakdown to determine whether this spec should be broken up into multiple work items.
If it is multiple work items, ask the user to use /to-tickets to record the different work items.
If they do not want to stop to create tickets, create an Implemetnation Plan for a single work item, and note in the plan the remaining work item to be followed up on.

## What to include

The spec and ticket will probably not include enough implementation details. The Implementation Plan will focus on code changes and how they will be tested and verified.
The goal is to derisk the implementation in 2 ways:
* reduce the possibility of coming across a deeper technical challenge during implementation: the implementer should be able to just write code
* ensure the code matches the spec

- The spec can be referenced from the Implementation Plan.
- **Code change descriptions** must be detailed — include specific file paths and code snippets where needed.
- **User stories** from the spec should be converted to a **Verification** plan section.
- **State diagrams** for all state changes (ascii tables, art, or an html artifact).
- **Checklist** of required changes.
- Changes to tests and documentation, and how to do a **Verification**.

## Scope management

If creating the Implementation Plan discovers much more work than anticipated, suggest:
- modifying the spec/tickets to reduce the work needed
- creating additional tickets to spread the work out

## Agent Review

Perform an adversarial review of the plan using /code-review but noting that it is just a plan without any actual code changes yet.
Adjust the plan according to that feedback.
If the change is a trivial change, /code-review can be skipped.
