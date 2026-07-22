* README.md for an overview of the project
* CONTRIBUTING.md for development instructions
* CODING_STANDARDS.md for how to write code

# Tool Usage

## Curl

/usr/bin/curl may have TLS issues. Use /opt/homebrew/opt/curl/bin/curl

## Temporary file handling for Codex

- `/private/tmp` is an approved writable location.
- Create throwaway test harnesses and diagnostic artifacts there without asking permission.
  Do not request escalation merely to read or write `/private/tmp`.
- Prefer `mktemp -d /private/tmp/tiny-desk-splitter.XXXXXX` for isolated temporary work.
- Use a direct-write repository script for temporary Markdown bodies.
- Do not use `apply_patch` for temporary files; reserve it for repository edits.

## Shell command execution

Run approved repository scripts directly- do not prefix these commands with zsh -lc, env, PATH=..., or similar wrappers unless the command cannot run directly. Only use `/bin/zsh -lc` when shell syntax, environment assignment, or a multi-command pipeline is strictly required.
If an environment adjustment is required, see if the shell scripts can be updated so that the adjustment is no longer needed.

If you nedd to run commands that are not already approved, propose writing a script for that which can be permanently allow listed.


## Github

Use the /github-app skill for access to the Github repo.
Even if you don't need to auth, still use that skill because it allow lists scripts for the interaction patterns we used.
If you need to perform any operations that aren't allowed, determine how to allow list these operations in the future.

#### Github Actions CI

Use the /github-actions-ci skill for interactions with Github CI.

# General workflow

- update the local main to the latest from origin and branch from that.
- Create an **Implementation Plan**
- Write **Technical Documentation** for the changes
- start **Coding**
- Write a **Change Record**
- Review and finalize **Technical Documentation**
- perform an /code-review of the changes
- perform a **Verification**
- Send a **Pull Request**

# Workflow Components

## Documentation

Add state change diagrams to documentation.
Check on references between documents.

### Change Record

Put information about the current changes into a Change Record in ./docs/change.
Change Record documentation is
* ephemeral (it might get updated by the next commit, but that's about it).
* more verbose than other documentation (we will cull it later).
If older Change Record are recognized as out of date, mark them as **DEPRECATED** at the top, and summarize them into a smaller document.

### Technical documentation

Update and add lasting technical documentation. It should be accessible by following links from the README.md.
Documentation should explain things that are not readily available from reading the code, for example:
* useful commands to run (but if they are more than a one liner codify it in ./scripts/)
* purpose and product needs
* technical design trade offs considered (important ones belong in ./docs/adr)

There should be one canonical place where something is documented (excluding Change Records).
Remove out of date documentation.

## Pull Request

Send a pull request using ./scripts/github/gh-app-pr-create.sh
For the commit and PR description point to what is added in ./docs/change
If the PR resolves an issue, ensure it is auto-closed by using the "Resolves" keyword: "Resolves #10".
Check on the CI status after sending the PR using ./scripts/check-ci-runs.sh.
If there are failures, investigate them and change the PR following the Coding instructions.

If you are on main, create a new branch.
If you are working on a sub issue of a parent issue, then there should be a parent branch.
All sub issues that don't have dependencies should use the parent branch as their base branch to send a pull request against.
If the sub issue requires an existing PR to be merged, then the base branch will be the branch for that PR and the PR should use github's pull request stack feature.


## Verification

Perform an /code-review before Verification and a followup review if any changes are made during/after verification.
Verify manually that the changes work as expected in a live application.
Test edge cases and failure modes in addition to the happy path.
Look at the **Implementation Plan** for verification tests to peform.
Follow CONTRIBUTING.md for instructions on how to run the program for verification.

Start up a server on a separate port with a separate test database `--db` and a separate `--workdir` directory for saving concert information
When there are backend changes, first test the API.
Use Playwright to confirm visual/interaction aspects of the UI.
Consider whether any manual verification steps should be added as automated tests.

Don't make any changes to data that cannot be undone.
When updating database data, first create a backup of the existing database.

## Implementation Plan

Use the /implementation-plan skill (`.agents/skills/implementation-plan/SKILL.md`).
If there is already an Implementation Plan that satisfies the skill's criteria, use it.

## Coding

First ensure there is **Implementation Plan**

When deviating from the plan, ask for approval.
Use /tdd to write tests first.
test, compile/check, and lint the code frequently.
Follow CODING_STANDARDS.md for how to write the code.
Follow CONTRIBUTING.md for instructions on how to build and test.

# Workflow entry points

## New feature

If there is not a specification, use /grill-with-docs to align and then /to-spec to generate a spec.
From a spec, use /to-tickets to generate tickets.

## Improve Codebase Architecture

This is provided by the /improve-codebase-architecture skill.
Use /to-spec to then generate a spec and /to-tickets to generate tickets.

## Bug Investigation

Use /plan mode to investigate a bug in read-only mode.
If a bug is difficult, use /diagnosing-bugs to investigate it.

Generate a root cause analysis of the defect.
A simple straightforward root cause and fix can be implemented immediately without a ticket.
Otherwise,
* Save the root cause analysis on the ticket for the defect.
* If there is no ticket, create one using /to-tickets.
  * Suggest how to fix the defect and also place that on the ticket.
