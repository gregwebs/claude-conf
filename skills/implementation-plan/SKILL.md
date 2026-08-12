---
name: implementation-plan
description: "Create a detailed Implementation Plan for a ticket or spec, corresponding to a single Pull Request."
metadata:
  inlined-from:
    - source: ~/.agents/skills/code-review/SKILL.md
      source-scope: "## Process"
      source-scope-sha256: "26477abdda062b77d1f11e4666a8ed60bbde57b6b50dceb74a0a0d73aed3b3e2"
      components:
        - source-section: "### 2. Identify the spec source"
          local-section: "### Identify the spec source"
        - source-section: "### 3. Identify the standards sources"
          local-section: "### Identify the standards sources"
---

## Overview

Create a detailed Implementation Plan for one work item. If an existing plan
already meets this skill's requirements, use it rather than creating another.

## Prerequisites

If you are running inline in the main conversation and have reason to believe
this turn is not on a reasoning-tier model, say so and ask whether to switch
before planning. If you are running as a subagent, do not ask — note the
limitation in your result and plan anyway.

### Identify the spec source

Use a user-supplied path or ticket first; then an accessible referenced issue;
then a matching tracked spec; then conversation context. If none exists,
suggest `/grill-with-docs` or `/to-spec` before planning.
If a ticket links to other related documentation or pull requests, fetch them as well if you have access.
If there is a parent issue or related issues that are completed, look at those completed issues. You can do this by looking at the commit history if the commit documents the issue.

### Identify the standards sources

Discover applicable tracked standards documents. `CONTEXT.md`, ADRs, and
conventional filenames are useful when present, but are not prerequisites.

## Scope management

Decide whether the work plausibly fits one pull request.
You can use the skill `/breakdown` as a guide, but do not to invoke it from inside planning.
If it does not, explain the split needed and suggest `/to-tickets`;

## What to include

The plan must give an implementer enough detail to execute without redesign.

High-level details:
- architectural overview
- the assumptions, failure modes, and relevant standards constraints.
- a diagram, table, or detailed description of changes in
  * connections
  * state transitions
- a pre-agreed TDD seam, or an explanation of why automated tests do not apply
- Review notes (put the text "not reviewed" in this section until it is reviewed)

Low-level details:
- detailed file-level type and function signature changes, including snippets for important non-obvious ideas
- tests to implement
- verifications to perform
- documentation updates
- a task checklist

Convert user stories into concrete tests or manual verification criteria.

## Review

Unless the change is trivial, Have an independent subagent perform an adversarial review of the plan. Review in this order and incorporate the findings into the plan:

1. **Spec** — completeness and scope.
2. **Architecture**
   - consult the installed `codebase-design` skill
   - module boundaries and trade-offs; use optional glossary and ADR context
3. **Quality** — standards, tests, and operational risks.

Present the revised plan as the reviewable output.
