#!/usr/bin/env bash
# Read an issue, authenticated as a GitHub App installation.
#
# Usage: gh-app-issue-get.sh --issue NUMBER [--repo OWNER/REPO]
#
# --repo defaults to the current directory's github.com origin remote.
# Requires a GitHub App set up per docs/change/2026-06-20-github-app-push.md
# (client-id, private-key.pem under ~/.config/github-app/, not tracked).
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
  json)
    gh_app_api_get "repos/${repo}/issues/${issue}"
    ;;
  md)
    # Concise human-readable rendering (title, metadata, body) so callers
    # don't need to pipe the full JSON through an extra jq/python step.
    gh_app_api_get "repos/${repo}/issues/${issue}" | jq -r '
      "# #\(.number) \(.title)",
      "state: \(.state)   labels: \([.labels[].name] | join(", "))",
      (if .parent_issue_url then "parent: #\(.parent_issue_url | sub(".*/";""))" else empty end),
      "",
      .body'
    ;;
  *)
    echo "unknown --format: $format (want json or md)" >&2
    exit 1
    ;;
esac
