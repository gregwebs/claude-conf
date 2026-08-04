#!/usr/bin/env bash
# Report GitHub Actions check runs for a commit.
#
# Usage: check-ci-runs.sh [--wait] [--job JOB_NAME] [COMMIT]
# COMMIT defaults to HEAD. With --wait, poll until the selected check runs complete.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_HELPER="$SCRIPT_DIR/../../github-app/scripts/gh-app-token.sh"

usage() {
  echo "usage: check-ci-runs.sh [--wait] [--job JOB_NAME] [COMMIT]" >&2
}

wait_for_result=false
job_filter=""
commit="HEAD"
while [ $# -gt 0 ]; do
  case "$1" in
    --wait)
      wait_for_result=true
      shift
      ;;
    --job)
      if [ -z "${2:-}" ]; then
        usage
        exit 2
      fi
      job_filter="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      usage
      exit 2
      ;;
    *)
      if [ "$commit" != "HEAD" ]; then
        usage
        exit 2
      fi
      commit="$1"
      shift
      ;;
  esac
done

REPO_ROOT="$(git rev-parse --show-toplevel)"
sha=$(git -C "$REPO_ROOT" rev-parse "$commit")
origin=$(git -C "$REPO_ROOT" config --get remote.origin.url)
repo=${origin#*github.com[:/]}
repo=${repo%.git}

if [ -x /opt/homebrew/opt/curl/bin/curl ]; then
  curl_bin=/opt/homebrew/opt/curl/bin/curl
else
  curl_bin=curl
fi

github_app_auth=false
github_app_secrets_dir="${GITHUB_APP_SECRETS_DIR:-$HOME/.config/github-app}"
if [ -r "$github_app_secrets_dir/client-id" ] \
  && [ -r "$github_app_secrets_dir/installation-id" ] \
  && [ -r "$github_app_secrets_dir/private-key.pem" ]; then
  if [ ! -r "$TOKEN_HELPER" ]; then
    echo "check-ci-runs: GitHub App token helper not found: $TOKEN_HELPER" >&2
    exit 1
  fi
  # shellcheck disable=SC1091
  source "$TOKEN_HELPER"
  github_app_auth=true
fi

if [ "$github_app_auth" = true ]; then
  interval=${CHECK_INTERVAL_SECONDS:-10}
else
  # Anonymous GitHub API reads have a low shared-IP rate limit.
  interval=${CHECK_INTERVAL_SECONDS:-60}
fi

# shellcheck disable=SC2016 # jq sees $job; the shell must not expand it.
latest_checks_query='
  [.check_runs[]
   | select(.app.slug == "github-actions")
   | select($job == "" or .name == $job)]
  | sort_by(.name, (.started_at // .created_at // ""))
  | group_by(.name)
  | map(max_by(.started_at // .created_at // ""))
  | sort_by(.name)
'

while true; do
  auth_args=()
  if [ "$github_app_auth" = true ]; then
    auth_args=(-H "Authorization: Bearer $(gh_app_token)")
  fi
  checks=$(
    "$curl_bin" -fsS \
      "${auth_args[@]}" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$repo/commits/$sha/check-runs?per_page=100" |
      jq -c --arg job "$job_filter" "$latest_checks_query"
  )

  if [ "$(jq 'length' <<<"$checks")" -eq 0 ]; then
    if [ -n "$job_filter" ]; then
      echo "$job_filter: not found for $sha" >&2
    else
      echo "CI checks: not found for $sha" >&2
    fi
    if [ "$wait_for_result" = true ]; then
      sleep "$interval"
      continue
    fi
    exit 2
  fi

  jq -r '.[] | "\(.name): \(.status) (\(.conclusion // "pending"))\n\(.html_url)"' <<<"$checks"

  if jq -e 'all(.[]; .status == "completed" and .conclusion == "success")' \
    >/dev/null <<<"$checks"; then
    exit
  fi

  if jq -e 'any(.[]; .status == "completed" and .conclusion != "success")' \
    >/dev/null <<<"$checks"; then
    exit 1
  fi

  if [ "$wait_for_result" = false ]; then
    exit 2
  fi
  sleep "$interval"
done
