#!/usr/bin/env bash
# Open an issue, authenticated as a GitHub App installation.
#
# Usage: gh-app-issue-create.sh --title TITLE \
#          [--repo OWNER/REPO] [--body TEXT | --body-file FILE] [--label LABEL]...
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

repo="" title="" body="" body_file="" labels=()
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    --body) body="$2"; shift 2 ;;
    --body-file) body_file="$2"; shift 2 ;;
    --label) labels+=("$2"); shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$repo" ] || repo=$(gh_app_default_repo) || { echo "--repo required (not in a github.com git repo)" >&2; exit 1; }
if [ -z "$title" ]; then
  echo "usage: $0 --title TITLE [--repo OWNER/REPO] [--body TEXT | --body-file FILE] [--label LABEL]..." >&2
  exit 1
fi

resolved_body=$(gh_app_resolve_body "$body" "$body_file")
labels_json=$(printf '%s\n' "${labels[@]:-}" | jq -R . | jq -s 'map(select(length > 0))')

payload=$(jq -n --arg title "$title" --arg body "$resolved_body" --argjson labels "$labels_json" \
  '{title: $title, body: $body, labels: $labels}')

gh_app_api_post "repos/${repo}/issues" "$payload"
