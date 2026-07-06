---
name: github-app
description: Create GitHub pull requests, issues, and issue/PR comments for this repo via the App-authenticated scripts in ./script/github-app/. Use when the user asks to open a PR, file an issue, or comment on an issue/PR from this project. Triggers on "open a PR", "send a pull request", "file an issue", "comment on the PR/issue".
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash(./script/github-app/*)
  - Bash(git push*)
  - Bash(git rev-parse*)
  - Bash(git branch*)
  - Bash(git status*)
---

# /github — GitHub PR / issue / comment via the App scripts

Thin wrappers in `script/github-app/` that hit the GitHub REST API authenticated as
the `greg-weber-claude-agent` GitHub App installation. They mint their own
short-lived (~9 min) token per call — nothing to log into. Each script prints
the resulting `html_url` on success; **always relay that URL back to the user.**

These are **outward-facing actions** (they publish to GitHub and notify people).
This skill only runs in response to a request the user typed in their terminal.
Confirm the target (repo, branch, title) before running if there's any ambiguity.

## The scripts

| Action | Script | Required args |
|---|---|---|
| Open a PR | `gh-app-pr-create.sh` | `--base BASE --head HEAD --title TITLE` |
| File an issue | `gh-app-issue-create.sh` | `--title TITLE` |
| Comment on issue/PR | `gh-app-issue-comment.sh` | `--issue NUMBER` (PRs count as issues here) |

Common optional args: `--repo OWNER/REPO`, `--body TEXT`, `--body-file FILE`.
Issue creation also takes repeatable `--label LABEL`.

`--repo` defaults to this directory's `github.com` origin remote — **omit it**
unless acting on a different repo.

## Body text: always use `--body-file`, never `--body`

Write the body to a temp file with the **Write tool**, then pass `--body-file`.
Do this even for one-liners. Reasons:

- This sandbox mangles `!` into `\!` in Bash-tool arguments and heredocs, so an
  inline `--body "...!..."` corrupts the body. The Write tool is unaffected.
- Multiline / Markdown bodies with backticks, quotes, and `$` are painful to
  quote safely on a command line.

```
# 1. Write the body
Write  $TMPDIR/pr-body.md   (Markdown PR/issue/comment body)
# 2. Pass it
./script/github-app/gh-app-pr-create.sh --base main --head my-branch \
  --title "..." --body-file "$TMPDIR/pr-body.md"
```

## Opening a PR

1. **The head branch must already be pushed to origin** — the API resolves
   `--head` against the remote. If it isn't, push first (the repo's git config
   pushes via the same App credentials). Confirm with the user before pushing if
   they haven't asked.
2. `--base` is usually `main`; `--head` is the current feature branch
   (`git rev-parse --abbrev-ref HEAD`).
3. Per this project's CLAUDE.md workflow, the **PR description should point to
   the change's entry in `./docs/change/`** — summarize there and reference it
   in the body.
4. Write the body file, run the script, relay the printed PR URL.

## Filing an issue

```
./script/github-app/gh-app-issue-create.sh --title "Title" \
  --body-file "$TMPDIR/issue-body.md" --label bug --label "needs triage"
```
`--label` repeats per label. Relay the printed issue URL.

## Commenting on an issue or PR

GitHub treats PR conversation comments as issue comments, so the **same script
and PR/issue number** work for both:
```
./script/github-app/gh-app-issue-comment.sh --issue 1 --body-file "$TMPDIR/comment.md"
```

## Failure modes

- **`403 Resource not accessible by integration`** — the installation lacks the
  needed permission scope (`Contents`/`Pull requests`/`Issues: write`). Granting
  it in the App settings also requires the owner to *accept* the upgraded grant
  at https://github.com/settings/installations. Report this to the user; you
  can't fix it from here.
- **`--repo required (not in a github.com git repo)`** — run from the repo, or
  pass `--repo OWNER/REPO`.
- **`422` on PR create** — usually the head branch isn't pushed, a PR already
  exists for that branch, or base == head. Check the error body the script
  prints to stderr.
- These scripts use `curl`/`jq` (not `gh`) on purpose: `gh` fails TLS against
  `api.github.com` in this sandbox. Don't substitute `gh`.

## Setup reference

All GitHub-interaction code (token minting, git credential helper, the
gh-app-*.sh scripts, lib.sh) lives in `./scripts/github/` and is tracked in
this repo. The only things that live outside the repo, in
`~/.config/github-app/` (not tracked, `chmod 700`/`600`), are the two actual
secrets:

- `client-id` — the App's client ID (used as the JWT `iss` claim)
- `private-key.pem` — the App's private key (signs the JWT)

The installation ID isn't a secret but should be placed in ~/.config/github-app/installation-id.
Override the secrets directory with `GITHUB_APP_SECRETS_DIR` if needed (default `~/.config/github-app`).
