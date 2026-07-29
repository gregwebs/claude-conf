#!/usr/bin/env bash
# Stable repository entry point for GitHub App operations.
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMPLEMENTATION="$REPOSITORY_ROOT/.agents/skills/github-app/scripts/gh-app.sh"
PUBLIC_COMMAND="./scripts/gh-app.sh"

export GH_APP_PROGRAM_NAME="$PUBLIC_COMMAND"

if [ "$#" -ge 1 ] \
  && { [ "${2:-}" = "--help" ] || [ "${2:-}" = "-h" ]; }; then
  help_output=$("$IMPLEMENTATION" "$@" 2>&1)
  internal_command="$REPOSITORY_ROOT/.agents/skills/github-app/scripts/gh-app-$1.sh"
  help_output="${help_output//$internal_command/$PUBLIC_COMMAND $1}"
  printf '%s\n' "$help_output"
  exit 0
fi

exec "$IMPLEMENTATION" "$@"
