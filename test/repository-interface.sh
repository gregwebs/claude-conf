#!/usr/bin/env bash
# Contract test for the repository's stable command-line interface.
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GITHUB_DISPATCHER="$REPOSITORY_ROOT/scripts/gh-app.sh"
CI_CHECKER="$REPOSITORY_ROOT/scripts/check-ci-runs.sh"

fail() {
  echo "test-repository-interface: $*" >&2
  exit 1
}

assert_json() {
  local query="$1" expected="$2"
  local actual
  actual=$(jq -r "$query" "$REPOSITORY_ROOT/.claude/settings.local.json")
  [ "$actual" = "$expected" ] || fail "expected $query to be $expected, got $actual"
}

assert_executable() {
  [ -x "$1" ] || fail "expected executable command: $1"
}

assert_readable() {
  [ -r "$1" ] || fail "expected readable dependency: $1"
}

assert_help() {
  local help_output
  if ! help_output=$(cd "$TEMP_ROOT" && "$@" --help 2>&1); then
    fail "expected --help to succeed: $*"
  fi
  case "$help_output" in
    *".agents/skills/"*|*"gh-app-"*".sh"*)
      fail "help exposed an internal implementation path: $help_output"
      ;;
  esac
}

if [ -d /private/tmp ]; then
  TEMP_ROOT=/private/tmp
else
  TEMP_ROOT=/tmp
fi

assert_json '.model' 'opusplan'
assert_json '.permissions.defaultMode' 'plan'

assert_executable "$GITHUB_DISPATCHER"
assert_executable "$CI_CHECKER"
assert_readable "$REPOSITORY_ROOT/.agents/skills/github-app/scripts/gh-app-token.sh"

assert_help "$GITHUB_DISPATCHER"
assert_help "$CI_CHECKER"
for command_name in \
  push \
  pr-create \
  pr-update \
  issue-get \
  issue-create \
  issue-update \
  issue-comment \
  issue-sub-add \
  actions-run-view \
  actions-job-log \
  actions-rerun-failed; do
  assert_help "$GITHUB_DISPATCHER" "$command_name"
done

unknown_output=$(mktemp "$TEMP_ROOT/claude-conf-interface.XXXXXX")
trap 'rm -f "$unknown_output"' EXIT
if (cd "$TEMP_ROOT" && "$GITHUB_DISPATCHER" unknown-command >"$unknown_output" 2>&1); then
  fail 'unknown dispatcher command succeeded'
fi
rg -q '^usage:' "$unknown_output" || fail 'unknown dispatcher command did not print usage'
if rg -q '\.agents/skills/|gh-app-[a-z-]+\.sh' "$unknown_output"; then
  fail 'unknown dispatcher command exposed an internal implementation path'
fi

if rg -n '\./scripts/github/|gh-app-[a-z-]+\.sh' \
  "$REPOSITORY_ROOT/.agents/skills" \
  --glob 'SKILL.md'; then
  fail 'workflow skills bypass the public scripts interface'
fi

echo 'repository interface contract passed'
