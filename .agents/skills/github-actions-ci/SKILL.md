---
name: github-actions-ci
description: Monitor, wait for, and diagnose this repository's GitHub Actions checks with ./scripts/check-ci-runs.sh. Use after pushing or opening/updating a PR, when asked to watch CI or verify a named job such as Playwright, or when a GitHub Actions check fails.
---

# GitHub Actions CI

Use the tracked helper as the single interface for check-run status. It selects
the host-compatible curl binary, resolves the repository and commit, and uses
GitHub App authentication when local App credentials are available.

## Monitor checks

Run one of these stable command shapes from the repository root:

```sh
./scripts/check-ci-runs.sh
./scripts/check-ci-runs.sh --wait
./scripts/check-ci-runs.sh --job playwright --wait
./scripts/check-ci-runs.sh --job playwright --wait COMMIT
```

The stable approval prefix is:

```text
./scripts/check-ci-runs.sh
```

## Rerun failed jobs

After confirming a failure is transient or unrelated to the change, rerun the
failed jobs for the workflow run with the GitHub App helper:

```sh
./scripts/github/gh-app-actions-rerun-failed.sh RUN_ID
```

The stable approval prefix is:

```text
./scripts/github/gh-app-actions-rerun-failed.sh
```

Use the workflow run ID from the failed job URL. This reruns only failed jobs;
it does not create a new workflow run or rerun successful jobs. Monitor the
replacement checks with `./scripts/check-ci-runs.sh --wait COMMIT`.

GitHub requires network access. In a restricted Codex sandbox, request network
escalation on the first call using that narrow prefix. Do not probe with raw
`curl` or first run the helper without network access when DNS failure is
expected. A persisted prefix approval can then match later invocations without
another prompt.

With `--wait`, keep the process running and poll its existing execution session
at intervals no longer than 30 seconds so the user continues to receive timely
updates. Do not start duplicate monitors. Authenticated polling defaults to ten
seconds; the helper backs off to sixty seconds when App credentials are absent
to respect GitHub's anonymous rate limit.

Exit status means:

- `0`: every selected check completed successfully.
- `1`: at least one selected check completed unsuccessfully.
- `2`: selected checks are pending or absent when not using `--wait`.

Always relay the job URL printed by the helper.

## Handle results

On success, run the unfiltered helper once to report the complete final CI
state when the repository workflow requires all jobs to pass.

On failure:

1. Open the printed job URL or use the GitHub App read helpers where they cover
   the needed metadata.
2. Identify the first substantive failing step; ignore teardown noise caused by
   the failure.
3. Reproduce with the repository's documented local command when the host
   supports it.
4. Make only in-scope changes, run the relevant local checks, push, and wait for
   the replacement CI run.
5. If Playwright cannot launch locally with the documented host-level `SIGTRAP`
   failure, record that limitation and treat Linux Playwright CI as the browser
   verification surface. Do not repeatedly request broader execution approval.

For CI architecture, artifacts, and Playwright-specific troubleshooting, read
`docs/playwright.md` rather than duplicating it here.
