---
name: implementation-plan
description: "Create a detailed Implementation Plan for a ticket or spec, corresponding to a single Pull Request."
---

# /implementation-plan

Create a detailed Implementation Plan for a ticket or spec. Each Implementation Plan corresponds to a single **Pull Request** (see AGENTS.md for Pull Request and Agent Review details).

Use /plan mode and a thinking model for the plan creation.

## Prerequisites

If there is already an **Implementation Plan** that satisfies the "What to include" criteria below, use it rather than creating a new one.

If there is already a spec, that is your starting point.
If not, use /grill-me-with-docs to align on changes and then /to-spec to first create a spec.
If this is a github issue, use the /github-app skill to retrieve the issue.

Use conversation context and /breakdown to determine whether this spec should be broken up into multiple work items.
If it is a single work item, then proceed to /implement it.
If it is multiple work items, ask the user to /to-tickets to record the different work items.

## What to include

The spec and ticket will not include enough implementation details. The Implementation Plan will focus on code changes and how they will be tested and verified:

- **Code change descriptions** must be detailed — include specific file paths and code snippets.
- **User stories** from the spec should be converted to a **Verification** plan section.
- The spec can be referenced from the Implementation Plan.
- **State diagrams** for all state changes (ascii tables, art, or an html artifact).
- **Checklist** of required changes.
- Changes to tests and documentation, and how to do **Verification** (see AGENTS.md for Verification details).

## Scope management

If creating the Implementation Plan discovers more work than anticipated, suggest:
- modifying the spec/tickets to reduce the work needed
- creating additional tickets to spread the work out

## Agent Review

Perform a review of the plan using /code-review but noting that it is just a plan without any actual code changes yet.
Adjust the plan according to that feedback.
If the change is a trivial change, /code-review can be skipped.
