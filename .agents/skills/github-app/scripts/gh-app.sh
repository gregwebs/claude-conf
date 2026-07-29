#!/usr/bin/env bash
# Stable dispatcher for GitHub App-authenticated repository operations.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
usage: $0 COMMAND [ARGS...]

commands:
  pr-create       Create a pull request
  pr-update       Update a pull request
  issue-get       Read an issue
  issue-create    Create an issue
  issue-update    Update an issue
  issue-comment   Comment on an issue or pull request
  issue-sub-add   Link a child issue to a parent

Run "$0 COMMAND --help" for command-specific arguments.
EOF
}

command_name="${1:-}"
case "$command_name" in
  --help|-h|"") usage; exit 0 ;;
  pr-create|pr-update|issue-get|issue-create|issue-update|issue-comment|issue-sub-add) ;;
  *) echo "unknown command: $command_name" >&2; usage >&2; exit 1 ;;
esac
shift

exec "$SCRIPT_DIR/gh-app-${command_name}.sh" "$@"
