#!/usr/bin/env bash
# Comment on an issue or pull request, authenticated as a GitHub App
# installation. (GitHub treats PRs as issues for the comments endpoint.)
#
# Usage: gh-app-issue-comment.sh --issue NUMBER \
#          [--repo OWNER/REPO] [--body TEXT | --body-file FILE]
#
# --repo defaults to the current directory's github.com origin remote.
# Requires a GitHub App set up per docs/change/2026-06-20-github-app-push.md
# (client-id, private-key.pem under ~/.config/github-app/, not tracked;
# installation granted Issues:write on the repo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/gh-app-token.sh"

repo="" issue="" body="" body_file=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --issue) issue="$2"; shift 2 ;;
    --body) body="$2"; shift 2 ;;
    --body-file) body_file="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$issue" ] || { [ -z "$body" ] && [ -z "$body_file" ]; }; then
  echo "usage: $0 --issue NUMBER [--repo OWNER/REPO] (--body TEXT | --body-file FILE)" >&2
  exit 1
fi

resolved_body=$(gh_app_resolve_body "$body" "$body_file")
payload=$(jq -n --arg body "$resolved_body" '{body: $body}')

gh_app_api_post "repos/${repo}/issues/${issue}/comments" "$payload"
