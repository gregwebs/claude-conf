#!/usr/bin/env bash
# Read GitHub Actions workflow-run metadata through the repository GitHub App.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

usage() {
  echo "usage: $0 RUN_ID [--repo OWNER/REPO] [--format summary|json]" >&2
}

run_id="" repo="" format="summary"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --repo) repo="${2:-}"; shift 2 ;;
    --format) format="${2:-}"; shift 2 ;;
    -*) echo "unknown argument: $1" >&2; usage; exit 2 ;;
    *)
      if [ -n "$run_id" ]; then usage; exit 2; fi
      run_id="$1"
      shift
      ;;
  esac
done

if ! [[ "$run_id" =~ ^[0-9]+$ ]]; then
  usage
  exit 2
fi
[ -n "$repo" ] || repo=$(gh_app_default_repo) || {
  echo "--repo required (not in a github.com git repo)" >&2
  exit 1
}

run=$(gh_app_api_get "repos/${repo}/actions/runs/${run_id}")
case "$format" in
  json)
    printf '%s\n' "$run" | jq .
    ;;
  summary)
    printf '%s\n' "$run" | jq -r '
      "workflow: \(.name)",
      "run:      \(.id) (attempt \(.run_attempt))",
      "status:   \(.status) (\(.conclusion // "pending"))",
      "event:    \(.event)",
      "commit:   \(.head_sha)",
      "branch:   \(.head_branch)",
      "started:  \(.run_started_at)",
      "updated:  \(.updated_at)",
      "url:      \(.html_url)"'
    ;;
  *)
    echo "unknown --format: $format (want summary or json)" >&2
    exit 2
    ;;
esac
