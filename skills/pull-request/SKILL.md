---
name: pull-request
description: Send a Github Pull Request of your work. Normally done after completing a ticket/issue. Check on CI and follow up on any failures.
metadata:
  short-description: Send a Github Pull Request and check on CI
---

## Definitions

PR=Pull Request

## Access

Access Github if the capability is available and the user instructs it.
* skills
  * /github-app skill: create the PR with `./scripts/gh-app.sh pr-create`
  * /github-actions-ci: check on CI with its bundled helper
* Github API or MCP
* github CLI 

## Branching

Discover the default branch; if you are on it, create a new branch.
If you are on a non-default branch, check against the lastest origin default branch to see if it your current branch has already been merged. If it has, put the work in a new branch off of the tip of the default branch (updated from origin).

If you are working on a sub issue of a parent issue, then look for an active parent branch to use as the base.
All sub issues that do not have dependencies should use the discovered default branch or the parent branch as their base branch.

If the issue requires an existing PR to be merged, then the base branch will be the branch for that PR.
Create it as a [Stacked PR](https://github.github.com/gh-stack/introduction/overview/).

## Description

For the PR description, use the `/document-changes` skill.
If the PR resolves an issue, ensure it is auto-closed by using the "Resolves" keyword: "Resolves #10".

## Check on CI

When CI access is available and the user requested PR follow-up, check the CI run for the PR.
If there are CI failures, investigate them and change the PR.

If the CI failures are not related to your work, suggest filing an issue or otherwise fixing them separately.
If they are related to your work, and the changes needed are not minor, ensure proper usage of standard flow for code changes.
