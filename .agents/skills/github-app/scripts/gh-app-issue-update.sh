#!/usr/bin/env bash
# Update an existing issue, authenticated as a GitHub App installation.
#
# Usage: gh-app-issue-update.sh --issue NUMBER [--repo OWNER/REPO]
#          [--title TITLE] [--body TEXT | --body-file FILE]
#          [--state open|closed] [--label LABEL]... [--clear-labels]
#
# --repo defaults to the current directory's github.com origin remote.
# At least one of --title, --body/--body-file, --state, --label, or
# --clear-labels is required.
# Passing --label replaces the issue's full label set with the provided labels.
# Passing --clear-labels replaces the issue's full label set with an empty set.
# Requires a GitHub App set up per docs/change/2026-06-20-github-app-push.md
# (client-id, private-key.pem under ~/.config/github-app/, not tracked;
# installation granted Issues:write on the repo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

usage() {
  echo "usage: $0 --issue NUMBER [--repo OWNER/REPO] [--title TITLE] [--body TEXT | --body-file FILE] [--state open|closed] [--label LABEL]... [--clear-labels]"
}

repo="" issue="" title="" body="" body_file="" state="" clear_labels=false labels=()
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --repo)      repo="$2";      shift 2 ;;
    --issue)     issue="$2";     shift 2 ;;
    --title)     title="$2";     shift 2 ;;
    --body)      body="$2";      shift 2 ;;
    --body-file) body_file="$2"; shift 2 ;;
    --state)     state="$2";     shift 2 ;;
    --label)     labels+=("$2"); shift 2 ;;
    --clear-labels) clear_labels=true; shift ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$issue" ]; then
  usage >&2
  exit 1
fi
if [ "$clear_labels" = true ] && [ "${#labels[@]}" -gt 0 ]; then
  echo "--clear-labels cannot be combined with --label" >&2
  exit 1
fi
if [ -z "$title" ] && [ -z "$body" ] && [ -z "$body_file" ] && [ -z "$state" ] && [ "${#labels[@]}" -eq 0 ] && [ "$clear_labels" = false ]; then
  echo "at least one of --title, --body, --body-file, --state, --label, or --clear-labels is required" >&2
  exit 1
fi

has_body=false
resolved_body=""
if [ -n "$body" ] || [ -n "$body_file" ]; then
  has_body=true
  resolved_body=$(gh_app_resolve_body "$body" "$body_file")
fi

has_labels=false
labels_json="[]"
if [ "$clear_labels" = true ]; then
  has_labels=true
elif [ "${#labels[@]}" -gt 0 ]; then
  has_labels=true
  labels_json=$(printf '%s\n' "${labels[@]}" | jq -R . | jq -s 'map(select(length > 0))')
fi

payload=$(jq -n \
  --arg title "$title" \
  --arg body "$resolved_body" \
  --arg state "$state" \
  --argjson has_body "$has_body" \
  --argjson has_labels "$has_labels" \
  --argjson labels "$labels_json" \
  '{
    title:  (if $title != "" then $title else null end),
    body:   (if $has_body then $body else null end),
    state:  (if $state != "" then $state else null end),
    labels: (if $has_labels then $labels else null end)
  } | with_entries(select(.value != null))')

gh_app_api_patch "repos/${repo}/issues/${issue}" "$payload"
