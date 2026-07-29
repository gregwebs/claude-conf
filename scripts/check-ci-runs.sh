#!/usr/bin/env bash
# Stable repository entry point for GitHub Actions CI status checks.
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMPLEMENTATION="$REPOSITORY_ROOT/.agents/skills/github-actions-ci/scripts/check-ci-runs.sh"
PUBLIC_COMMAND="./scripts/check-ci-runs.sh"

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  help_output=$("$IMPLEMENTATION" "$@" 2>&1)
  help_output="${help_output//$IMPLEMENTATION/$PUBLIC_COMMAND}"
  printf '%s\n' "$help_output"
  exit 0
fi

exec "$IMPLEMENTATION" "$@"
