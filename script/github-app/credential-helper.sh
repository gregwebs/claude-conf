#!/usr/bin/env bash
# git credential helper: mints a fresh GitHub App installation access token
# on every invocation by signing a JWT with the App's private key.
#
# Wire this up per-repo (not globally) via local git config, e.g.:
#   git config credential."https://github.com".helper "$(pwd)/scripts/github/credential-helper.sh"
#   git config credential."https://github.com".username x-access-token
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/gh-app-token.sh"

op="${1:-}"
# git also calls `store` and `erase`; tokens are minted fresh each time, so
# there's nothing to persist or clean up.
if [ "$op" != "get" ]; then
  exit 0
fi

# Drain stdin (git sends key=value request lines) - we don't need them since
# this helper only ever answers for github.com.
cat >/dev/null

token=$(gh_app_token)

printf 'username=x-access-token\n'
printf 'password=%s\n' "$token"
