---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

# Overview

The following is similar to the /implement personal skill but ensures
* a thorough planning phase at the beginning
* a Pull Request at the end

# Flow

Use /implementation-plan to generate a detailed Implementation Plan.
The user does not need to approve the plan if it was approved via /code-review.
After the plan is approved, exit /plan mode and use an efficient coding model.

Implement the work described by the Implementation Plan.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work and send a Pull Request.
