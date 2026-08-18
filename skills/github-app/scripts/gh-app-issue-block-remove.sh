#!/usr/bin/env bash
# Remove a blocked-by dependency between two issues, authenticated as a
# GitHub App installation.
#
# Usage: gh-app-issue-block-remove.sh --blocked NUMBER --blocker NUMBER
#
# Requires a GitHub App set up per the Setup reference in the /github-app skill
# with installation granted Issues:write on the repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

usage() {
  echo "usage: $0 --blocked NUMBER --blocker NUMBER [--repo OWNER/REPO]"
}

repo="" blocked="" blocker=""
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --repo) repo="$2"; shift 2 ;;
    --blocked) blocked="$2"; shift 2 ;;
    --blocker) blocker="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$blocked" ] || [ -z "$blocker" ]; then
  usage >&2
  exit 1
fi

blocker_id=$(gh_app_api_get "repos/${repo}/issues/${blocker}" | jq -r '.id')
if [ -z "$blocker_id" ] || [ "$blocker_id" = "null" ]; then
  echo "could not resolve database id for blocker issue ${blocker}" >&2
  exit 1
fi

gh_app_api_delete "repos/${repo}/issues/${blocked}/dependencies/blocked_by/${blocker_id}"
