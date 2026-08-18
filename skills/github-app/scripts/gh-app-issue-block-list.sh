#!/usr/bin/env bash
# List the issues an issue is blocked by and the issues it blocks, authenticated
# as a GitHub App installation.
#
# Usage: gh-app-issue-block-list.sh --issue NUMBER [--format json|md]
#
# Requires a GitHub App set up per the Setup reference in the /github-app skill
# with installation granted Issues:write on the repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

usage() {
  echo "usage: $0 --issue NUMBER [--repo OWNER/REPO] [--format json|md]"
}

repo="" issue="" format="json"
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --repo) repo="$2"; shift 2 ;;
    --issue) issue="$2"; shift 2 ;;
    --format) format="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$issue" ]; then
  usage >&2
  exit 1
fi

case "$format" in
  json|md) ;;
  *) echo "unknown --format: $format (want json or md)" >&2; exit 1 ;;
esac

blocked_by=$(gh_app_api_get "repos/${repo}/issues/${issue}/dependencies/blocked_by")
blocking=$(gh_app_api_get "repos/${repo}/issues/${issue}/dependencies/blocking")

case "$format" in
  json)
    jq -n --argjson blocked_by "$blocked_by" --argjson blocking "$blocking" \
      '{blocked_by: $blocked_by, blocking: $blocking}'
    ;;
  md)
    jq -n --argjson blocked_by "$blocked_by" --argjson blocking "$blocking" -r '
      def numbers: [.[] | "#\(.number)"] | if length > 0 then join(", ") else "none" end;
      "blocked by: \($blocked_by | numbers)",
      "blocking: \($blocking | numbers)"'
    ;;
esac
