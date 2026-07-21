---
name: to-tickets
description: Break a plan, spec, or conversation into tracer-bullet GitHub issues for this repo, creating a parent tracking issue with sub-issues when publishing multiple tickets.
disable-model-invocation: true
metadata:
  short-description: Create project tickets with a parent tracking issue when needed.
---

# /to-tickets - project wrapper

This project shadows the personal `to-tickets` skill so multi-ticket breakdowns
are published with a parent tracking issue and native GitHub sub-issue links.

## Delegate first

Read `~/.agents/skills/to-tickets/SKILL.md`, the base skill's canonical path,
and follow its full process: gather context, draft vertical slices, quiz the
user, iterate until approved, and publish.

If that base file does not exist on this machine, stop and tell the user the
personal `to-tickets` skill is missing. This wrapper intentionally depends on
the personal skill instead of vendoring its process.

## Publishing override for this repo

This section replaces the base skill's publish step.

Create all issues with `./scripts/github/gh-app-issue-create.sh`. Write issue
bodies to temp files and pass them with `--body-file`; never pass Markdown with
`--body`.

After each create command, extract the issue number strictly from the printed
URL. It must match `https://github.com/<owner>/<repo>/issues/<digits>` for this
repo's origin. If extraction fails, stop and report the URL instead of passing a
garbage number to another script.

If the approved breakdown has exactly one ticket, keep the base behavior: create
one `ready-for-agent` issue and do not create a parent issue.

If the approved breakdown has two or more tickets:

1. Create a parent tracking issue first.
   - Title: the short name of the work.
   - Body: the source spec verbatim, or a synthesized spec if working only from
     conversation, prefixed with one line saying this is a tracking issue whose
     sub-issues are the implementation tickets.
   - Labels: none.
2. Create child issues in dependency order.
   - Apply the `ready-for-agent` label.
   - Use the base issue template.
   - Include `## Parent` with a reference to the parent issue number.
3. After each child issue is created, attempt:
   `./scripts/github/gh-app-issue-sub-add.sh --parent N --child M`
4. Sub-issue linking is failure-tolerant. If linking fails because of a 403,
   422, rate limit, or similar API issue, record the failure, keep creating the
   remaining children, and report all link outcomes at the end.
5. After all children are created, update the parent with
   `./scripts/github/gh-app-issue-update.sh --issue N --body-file FILE`,
   re-sending the full body plus an appended `## Implementation tickets`
   section. List every child URL in dependency order and note any native
   sub-issue links that failed.

Relay all created issue URLs back to the user, parent first, including any
sub-issue link failures.
