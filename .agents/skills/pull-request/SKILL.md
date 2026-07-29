---
name: pull-request
description: Send a Github Pull Request of your work. Normally done after completing a ticket/issue. Check on CI and follow up on any failures.
metadata:
  short-description: Send a Github Pull Request and check on CI
---

## Definitions

PR=Pull Request

## Access

Access Github according to the user's preference (as stated in AGENTS.md/CLAUDE.md or project memory):
* skills
  * /github-app skill: create the PR with gh-app-pr-create.sh
  * /github-actions-ci: check on CI with check-ci-runs.sh
* Github API or MCP
* github CLI 

## Branching

If you are on the default branch (main), create a new branch.
If you are working on a sub issue of a parent issue, then look for an active parent branch to use as the base.
All sub issues that don't have dependencies should either use main or the parent branch as their base branch.
If the sub issue requires an existing PR to be merged, then the base branch will be the branch for that PR and the PR should be created as [Stacked PR](https://github.github.com/gh-stack/introduction/overview/).

## Description

For the PR description use the **Change Record** described below.
If the PR resolves an issue, ensure it is auto-closed by using the "Resolves" keyword: "Resolves #10".

## Check on CI

Check on the CI run for the PR.
If there are CI failures, investigate them and change the PR.

If the CI failures are not related to your work, suggest filing an issue or otherwise fixing them separately.
If they are related to your work, and the changes needed are not minor, ensure proper usage of standard flow for code changes.

## Change Record Contents

Change Record documentation is
* ephemeral- describing a moment in time- it will not be updated
* more verbose than normal documentation that must be kept up to date

Avoid including information that is already explained in the issue/ticket (the spec).
We should include information useful for implementing furture related issues/tickets, particularly if this issue/ticket has a parent issue and follow-on work. This includes:
* Technical design choices
* A high level summary of changes
* A lower level summary of changes done by pointing to the places in code that were changed and mostly letting the code speak for itself.
* Checklist items performed
* Verifications performed
