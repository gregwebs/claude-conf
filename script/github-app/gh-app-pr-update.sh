#!/usr/bin/env bash
# Update an existing pull request, authenticated as a GitHub App installation.
# The PR must be in draft state; updates to non-draft PRs are rejected.
#
# Usage: gh-app-pr-update.sh --pr NUMBER [--repo OWNER/REPO]
#          [--title TITLE] [--body TEXT | --body-file FILE]
#          [--base BASE] [--state open|closed]
#
# --repo defaults to the current directory's github.com origin remote.
# At least one of --title, --body/--body-file, --base, or --state is required.
# Requires a GitHub App set up per docs/change/2026-06-20-github-app-push.md
# (client-id, private-key.pem under ~/.config/github-app/, not tracked;
# installation granted Contents:write + Pull requests:write on the repo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/gh-app-token.sh"

repo="" pr="" title="" body="" body_file="" base="" state=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)      repo="$2";      shift 2 ;;
    --pr)        pr="$2";        shift 2 ;;
    --title)     title="$2";     shift 2 ;;
    --body)      body="$2";      shift 2 ;;
    --body-file) body_file="$2"; shift 2 ;;
    --base)      base="$2";      shift 2 ;;
    --state)     state="$2";     shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$pr" ]; then
  echo "usage: $0 --pr NUMBER [--repo OWNER/REPO] [--title TITLE] [--body TEXT | --body-file FILE] [--base BASE] [--state open|closed]" >&2
  exit 1
fi
if [ -z "$title" ] && [ -z "$body" ] && [ -z "$body_file" ] && [ -z "$base" ] && [ -z "$state" ]; then
  echo "at least one of --title, --body, --body-file, --base, or --state is required" >&2
  exit 1
fi

pr_json=$(gh_app_api_get "repos/${repo}/pulls/${pr}")
is_draft=$(printf '%s' "$pr_json" | jq -r '.draft')
if [ "$is_draft" != "true" ]; then
  echo "error: PR #${pr} is not a draft; only draft PRs may be updated via this script" >&2
  exit 1
fi

has_body=false
resolved_body=""
if [ -n "$body" ] || [ -n "$body_file" ]; then
  has_body=true
  resolved_body=$(gh_app_resolve_body "$body" "$body_file")
fi

payload=$(jq -n \
  --arg title "$title" \
  --arg body "$resolved_body" \
  --arg base "$base" \
  --arg state "$state" \
  --argjson has_body "$has_body" \
  '{
    title: (if $title != "" then $title else null end),
    body:  (if $has_body then $body else null end),
    base:  (if $base  != "" then $base  else null end),
    state: (if $state != "" then $state else null end)
  } | with_entries(select(.value != null))')

gh_app_api_patch "repos/${repo}/pulls/${pr}" "$payload"
