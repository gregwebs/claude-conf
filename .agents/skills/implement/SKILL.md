---
name: implement
description: "Implement a piece of work based on a spec or ticket. Create a plan. Review the plan and changes."
---

# Agent Delegation

Orchestrate subagents to minimize context and cost.
The `planner` subagent is smarter and more costly and produces the design.
The `implementer` subagent implements the plan and is designed to lower costs.

Artifacts are passed between agents with the goal that agents start with a summary of all useful information from other agents: this minimizes re-exploration.

Start every planner, reviewer, and implementer delegation without inherited
conversation history. In Codex use `fork_turns="none"`; use the equivalent
empty-context option on other platforms. Give the delegate only its requested
action and the artifact or source paths it needs. Do not paste the conversation
transcript into the delegation prompt.

Use `.md` artifacts for every sub-agent request. At the start of the workflow, create 
task-scoped temporary directory outside the repository. Do not commit its
contents. Pass absolute artifact paths between agents.

# Flow

## Phase 1 - A good plan

Delegate planning to a fresh `planner` subagent using `/implementation-plan`.
Pass it `task-brief.md` with contents:
* For a single user statement that doesn't refereance a larger conversation, give it the user request verbatim.
* Otherwise, summarize the conversation
Persist its output as `implementation-plan.md`.

## Phase 2 - Plan execution

Delegate to a fresh `implementer` sub-agent with only
* `task-brief.md`
* `implementation-plan.md`

If the required implementer delegation is unavailable, stop after
planning and ask the user for an implementer/model handoff (the /handoff skill may be available). Do not execute the plan inline on the planning model.


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
