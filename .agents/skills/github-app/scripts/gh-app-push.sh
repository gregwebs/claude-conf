#!/usr/bin/env bash
# Push the current branch to origin using the GitHub App credential helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
HELPER="$SCRIPT_DIR/credential-helper.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "usage: $0"
  echo "Push the current non-main branch to origin with GitHub App authentication."
  exit 0
fi

branch="$(git -C "$REPO_ROOT" symbolic-ref --quiet --short HEAD)" || {
  echo "gh-app-push: HEAD is detached; check out a branch first" >&2
  exit 2
}

if [[ "$branch" == "main" ]]; then
  echo "gh-app-push: refusing to push main; check out a working branch first" >&2
  exit 2
fi

exec git \
  -C "$REPO_ROOT" \
  -c "credential.https://github.com.helper=$HELPER" \
  -c credential.https://github.com.username=x-access-token \
  push --set-upstream origin "$branch"
