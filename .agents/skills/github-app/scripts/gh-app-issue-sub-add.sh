#!/usr/bin/env bash
# Link an existing issue as a sub-issue of a parent issue, authenticated as a
# GitHub App installation.
#
# Usage: gh-app-issue-sub-add.sh --parent NUMBER --child NUMBER [--repo OWNER/REPO]
#
# --repo defaults to the current directory's github.com origin remote.
# Requires a GitHub App set up per docs/change/2026-06-20-github-app-push.md
# (client-id, private-key.pem under ~/.config/github-app/, not tracked;
# installation granted Issues:write on the repo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

usage() {
  echo "usage: $0 --parent NUMBER --child NUMBER [--repo OWNER/REPO]"
}

repo="" parent="" child=""
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --repo) repo="$2"; shift 2 ;;
    --parent) parent="$2"; shift 2 ;;
    --child) child="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$parent" ] || [ -z "$child" ]; then
  usage >&2
  exit 1
fi

child_id=$(gh_app_api_get "repos/${repo}/issues/${child}" | jq -r '.id')
if [ -z "$child_id" ] || [ "$child_id" = "null" ]; then
  echo "could not resolve database id for child issue ${child}" >&2
  exit 1
fi

payload=$(jq -n --argjson child_id "$child_id" '{sub_issue_id: $child_id}')

gh_app_api_post "repos/${repo}/issues/${parent}/sub_issues" "$payload"
