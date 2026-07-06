#!/usr/bin/env bash
# Open a pull request, authenticated as a GitHub App installation.
#
# Usage: gh-app-pr-create.sh --base BASE --head HEAD --title TITLE \
#          [--repo OWNER/REPO] [--body TEXT | --body-file FILE] [--draft]
#
# --repo defaults to the current directory's github.com origin remote.
# Requires a GitHub App set up per docs/change/2026-06-20-github-app-push.md
# (client-id, private-key.pem under ~/.config/github-app/, not tracked;
# installation granted Contents:write + Pull requests:write on the repo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/gh-app-token.sh"

repo="" base="" head="" title="" body="" body_file="" draft="false"
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --base) base="$2"; shift 2 ;;
    --head) head="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    --body) body="$2"; shift 2 ;;
    --body-file) body_file="$2"; shift 2 ;;
    --draft) draft="true"; shift 1 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$base" ] || [ -z "$head" ] || [ -z "$title" ]; then
  echo "usage: $0 --base BASE --head HEAD --title TITLE [--repo OWNER/REPO] [--body TEXT | --body-file FILE] [--draft]" >&2
  exit 1
fi

resolved_body=$(gh_app_resolve_body "$body" "$body_file")
payload=$(jq -n --arg title "$title" --arg head "$head" --arg base "$base" --arg body "$resolved_body" --argjson draft "$draft" \
  '{title: $title, head: $head, base: $base, body: $body, draft: $draft}')

gh_app_api_post "repos/${repo}/pulls" "$payload"
