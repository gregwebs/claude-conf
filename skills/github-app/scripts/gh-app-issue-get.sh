#!/usr/bin/env bash
# Read an issue, authenticated as a GitHub App installation.
#
# Usage: gh-app-issue-get.sh --issue NUMBER
#
# Requires a GitHub App set up per the Setup reference in the /github-app skill.
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
    issue_json=$(gh_app_api_get "repos/${repo}/issues/${issue}")
    # Dependency lookups are failure-tolerant: a repo without issue
    # dependencies enabled (or an API version mismatch) must not break a
    # plain issue read.
    blocked_by=$(gh_app_api_get "repos/${repo}/issues/${issue}/dependencies/blocked_by" 2>/dev/null) || blocked_by='[]'
    blocking=$(gh_app_api_get "repos/${repo}/issues/${issue}/dependencies/blocking" 2>/dev/null) || blocking='[]'
    jq -n --argjson issue "$issue_json" --argjson blocked_by "$blocked_by" --argjson blocking "$blocking" -r '
      def numbers: [.[] | "#\(.number)"] | if length > 0 then join(", ") else "none" end;
      "# #\($issue.number) \($issue.title)",
      "state: \($issue.state)   labels: \([$issue.labels[].name] | join(", "))",
      (if $issue.parent_issue_url then "parent: #\($issue.parent_issue_url | sub(".*/";""))" else empty end),
      "blocked by: \($blocked_by | numbers)",
      "blocking: \($blocking | numbers)",
      "",
      $issue.body'
    ;;
  *)
    echo "unknown --format: $format (want json or md)" >&2
    exit 1
    ;;
esac
