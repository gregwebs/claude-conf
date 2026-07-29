---
name: implementation-plan
description: "Create a detailed Implementation Plan for a ticket or spec, corresponding to a single Pull Request."
model: "opus"
---

## Overview

Create a detailed Implementation Plan for a ticket or spec.

## Model/Agent

If you are running inline in the main conversation and have reason to believe
this turn is not on a reasoning-tier model, say so and ask whether to switch
before planning. If you are running as a subagent, do not ask — note the
limitation in your result and plan anyway.

## Prerequisites

If there is already an **Implementation Plan** that satisfies the "What to include" criteria below, use it rather than creating a new one.

If there is already a spec, that is your starting point.
Identify the spec source according to the instructions in the /code-review skill.
If there is no spec, suggest using /grill-with-docs to align on changes or /to-spec to first create a spec.

## Scope management

An Implementation Plan should be a single work item.
Use /breakdown to determine whether this spec should actually be broken up into multiple work items.
We may not realize that multiple work items are apropriate until after creating the Implementation Plan and discovering there is much more work than the spec anticipated.
In either case, suggest
- creating additional tickets to spread the work out with /to-tickets
- modifying the spec/tickets to reduce the work needed

## What to include

The spec and ticket will not include enough implementation details for a complex change. The Implementation Plan will focus on code changes and how they will be tested and verified.
The goal is to derisk the implementation in 3 ways:
* ensure the code matches the spec
* ensure a sound architecture and quality set of changes
* reduce the possibility of coming across a deeper technical challenge during implementation: the implementer should be able to just write code

The spec can be referenced from the Implementation Plan.
- **User stories** from the spec should be converted to the **Tests** or **Verification** section of the Implementation Plan.

Things to include:
- **Code change descriptions** must be detailed — include specific file paths and code snippets where needed.
- **State diagrams** for all state changes (ascii tables, art, or an html artifact).
- **Checklist** of required changes.
- **Tests** various cases that should be tested.
- **Documentation** to update
- **Verification** steps

## Review

If the change is a trivial change, review can be skipped.
Review must be done by a separate subagent.

Perform an adversarial review of the plan by a subagent. There are 3 tracks to review, in this order:
* **Spec** Does it meet the spec?
* **Architecture** Does it improve or degrade the architecture of the codebase?
* **Qualityh Standards** Does it meet our standards, and are these quality technical changes?

### Identify the standards sources

Identify the standards sources according to the instructions in the /code-review skill.

### Architecture review

Read the project's domain glossary (`CONTEXT.md`) and any ADRs in the area you're touching first.

**ADR conflicts**: any ADR conflicts should be surfaced to the user. Contradictions are not forbidden but should be well motivated and approved.
**Use CONTEXT.md vocabulary for the domain, and the `/codebase-design` vocabulary for the architecture.** If `CONTEXT.md` defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

Determine if any of these changes introduce shallow, complex,or small modules:

- Does understanding one concept require bouncing between many small modules?
- Are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Do tightly-coupled modules leak across their seams?
- Which parts are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.
