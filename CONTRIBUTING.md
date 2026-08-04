## Duplication

Some skill information is duplicated to leverage mattpocock/skills but alter/override flows.
We document this in the metadata section of the skill.

```
metadata:
  inlined-from:
```

Checks for drift are done with

```
./scripts/check-skill-inlines.sh
```

## Command interface tests

The stable repository entry point for GitHub App work is `./scripts/gh-app.sh`;
its bundled implementation is internal and must not be invoked directly. The
GitHub Actions skill exposes its bundled checker directly through
`${CLAUDE_SKILL_DIR}/scripts/check-ci-runs.sh`, so target repositories do not
need to provide a wrapper. Smoke-test these interfaces with:

```text
/github-app        -> ./scripts/gh-app.sh -> bundled dispatcher
/github-actions-ci -> bundled ${CLAUDE_SKILL_DIR}/scripts/check-ci-runs.sh
```

```sh
./test/repository-interface.sh
```

For local validation, run:

```sh
./test/repository-interface.sh
./scripts/check-skill-inlines.sh
git diff --check
```

The contract needs `jq`, Bash, OpenSSL, and the installed skills named by
provenance. ShellCheck and optional skill validation need separately installed
tools; report unavailable tools rather than treating CI as coverage.
