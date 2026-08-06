#!/usr/bin/env bash
# Download a GitHub Actions job's complete plain-text log through the GitHub App.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

usage() {
  echo "usage: $0 JOB_ID [--repo OWNER/REPO] [--output FILE]" >&2
}

job_id="" repo="" output=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --repo) repo="${2:-}"; shift 2 ;;
    --output) output="${2:-}"; shift 2 ;;
    -*) echo "unknown argument: $1" >&2; usage; exit 2 ;;
    *)
      if [ -n "$job_id" ]; then usage; exit 2; fi
      job_id="$1"
      shift
      ;;
  esac
done

if ! [[ "$job_id" =~ ^[0-9]+$ ]]; then
  usage
  exit 2
fi
[ -n "$repo" ] || repo=$(gh_app_default_repo) || {
  echo "--repo required (not in a github.com git repo)" >&2
  exit 1
}

gh_app_api_download "repos/${repo}/actions/jobs/${job_id}/logs" "$output"
if [ -n "$output" ]; then
  echo "Downloaded job ${job_id} log to ${output}." >&2
fi
