---
name: github-app
description: Read and update GitHub issues, push branches, and create or update pull requests, issues, and comments for this repo via the App-authenticated scripts in ./scripts/github/. Use for GitHub reads or writes, including "open a PR", "send a pull request", "file/read/update an issue", "comment on the PR/issue", or an App-authenticated push.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash(./scripts/github/*)
  - Bash(./scripts/github/gh-app.sh*)
  - Bash(git push*)
  - Bash(git rev-parse*)
  - Bash(git branch*)
  - Bash(git status*)
  - Bash(git commit*)
---

# /github-app — GitHub PR / issue / comment via the App scripts

Thin wrappers in `scripts/github/` that hit the GitHub REST API authenticated as
the `greg-weber-claude-agent` GitHub App installation. They mint their own
short-lived (~9 min) token per call — nothing to log into. Each script prints
the resulting `html_url` on success; **always relay that URL back to the user.**

These are **outward-facing actions** (they publish to GitHub and notify people).
This skill only runs in response to a request the user typed in their terminal.
Confirm the target (repo, branch, title) before running if there's any ambiguity.

## The scripts

| Action | Dispatcher command | Required args |
|---|---|---|
| Open a PR | `gh-app.sh pr-create` | `--base BASE --head HEAD --title TITLE` |
| Read an issue | `gh-app.sh issue-get` | `--issue NUMBER` |
| File an issue | `gh-app.sh issue-create` | `--title TITLE` |
| Link sub-issue | `gh-app.sh issue-sub-add` | `--parent NUMBER --child NUMBER` |
| Comment on issue/PR | `gh-app.sh issue-comment` | `--issue NUMBER` (PRs count as issues here) |

Common optional args: `--repo OWNER/REPO`, `--body TEXT`, `--body-file FILE`.
Issue creation also takes repeatable `--label LABEL`.

`--repo` defaults to this directory's `github.com` origin remote — **omit it**
unless acting on a different repo.

## Permission-efficient command shapes

Use the repository dispatcher directly. Do not prefix it with `PATH=...`, call
the GitHub API with raw `curl`, or substitute `gh`. The dispatcher and git
credential helper select `/opt/homebrew/opt/curl/bin/curl` internally when it
exists, so the command remains compatible with a narrow persistent approval
rule.

Stable command prefixes are:

```text
./scripts/github/gh-app.sh
git push
```

GitHub requires network access. In a restricted Codex sandbox, request network
escalation on the first attempt with the narrow dispatcher or `git push` prefix;
do not first run a command that is expected to fail DNS and then retry it. A
previously persisted approval can then match without another prompt.

Use the `github-actions-ci` skill for check status and waiting; do not use raw
Actions API calls from this skill.

## Body text: always use `--body-file`, never `--body`

Write the body to a temp file, then pass `--body-file`. Do this even for
one-liners.

In Codex, create these temp body files with `exec_command` and a direct write
under `/private/tmp` (for example, `printf '%s\n' 'body text' >
/private/tmp/pr-body.md`). Do **not** use `apply_patch` for `/private/tmp`
body files; `apply_patch` is for repository edits and can trigger an
unnecessary approval prompt for absolute paths outside the workspace.

Do **not** ask the user for permission before creating these temp body files
under `/private/tmp`. They are required workflow scratch files, they are outside
the repo, and `/private/tmp` is an allowed writable temp location in Codex.
Only ask for approval if the GitHub action itself is ambiguous or if a command
requires escalated permissions.

Reasons:

- This sandbox mangles `!` into `\!` in Bash-tool arguments and heredocs, so an
  inline `--body "...!..."` corrupts the body. The Write tool is unaffected.
- Multiline / Markdown bodies with backticks, quotes, and `$` are painful to
  quote safely on a command line.

```
# 1. Write the body to /private/tmp/pr-body.md
# 2. Pass it
./scripts/github/gh-app.sh pr-create --base main --head my-branch \
  --title "..." --body-file /private/tmp/pr-body.md
```

## Opening a PR

1. **The head branch must already be pushed to origin** — the API resolves
   `--head` against the remote. If it isn't, push first (the repo's git config
   pushes via the same App credentials). Confirm with the user before pushing if
   they haven't asked.
2. `--base` is usually `main`; `--head` is the current feature branch
   (`git rev-parse --abbrev-ref HEAD`). Use plain `git push`; the configured
   credential helper handles App authentication and curl selection.
3. Per this project's CLAUDE.md workflow, the **PR description should point to
   the change's entry in `./docs/change/`** — summarize there and reference it
   in the body.
4. Write the body file, run the script, relay the printed PR URL.

## Filing an issue

```
./scripts/github/gh-app.sh issue-create --title "Title" \
  --body-file "$TMPDIR/issue-body.md" --label bug --label "needs triage"
```
`--label` repeats per label. Relay the printed issue URL.

## Commenting on an issue or PR

GitHub treats PR conversation comments as issue comments, so the **same script
and PR/issue number** work for both:
```
./scripts/github/gh-app.sh issue-comment --issue 1 --body-file "$TMPDIR/comment.md"
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
  `api.github.com` in this sandbox. They automatically prefer the Homebrew curl
  required on this host. Don't add a `PATH` prefix or substitute `gh`.

## Setup reference

All GitHub-interaction code (token minting, git credential helper, the
gh-app-*.sh scripts, lib.sh) lives in `./scripts/github/` and is tracked in
this repo. The only things that live outside the repo, in
`~/.config/github-app/` (not tracked, `chmod 700`/`600`), are the two actual
secrets:

- `client-id` — the App's client ID (used as the JWT `iss` claim)
- `private-key.pem` — the App's private key (signs the JWT)

The installation ID isn't a secret but should be placed in `~/.config/github-app/installation-id`.
Override the secrets directory with `GITHUB_APP_SECRETS_DIR` if needed (default `~/.config/github-app`).

Full write-up and history: `docs/change/2026-06-20-github-app-push.md` and
`docs/change/2026-07-01-github-scripts-tracked.md`.
