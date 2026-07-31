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

## Repository command interface tests

The stable entry points for GitHub work are `./scripts/gh-app.sh` and
`./scripts/check-ci-runs.sh`. Their bundled implementations are internal and
must not be invoked directly. Smoke-test the public interface with:

```text
workflow skills
      |
      v
./scripts/{gh-app,check-ci-runs}.sh
      |
      v
bundled skill implementations
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
