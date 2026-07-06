#!/usr/bin/env bash
# Shared helpers for the gh-app-*.sh scripts in this directory. These call
# the GitHub REST API directly (not the gh CLI) using a token minted from a
# GitHub App installation - see ./gh-app-token.sh in this directory.
set -euo pipefail

# Best-effort "owner/repo" from the current directory's origin remote.
gh_app_default_repo() {
  local url
  url=$(git config --get remote.origin.url 2>/dev/null) || return 1
  url=${url#*github.com[:/]}
  url=${url%.git}
  printf '%s' "$url"
}

# Resolve a --body/--body-file pair into final body text (file wins if both given).
gh_app_resolve_body() {
  local body="$1" body_file="$2"
  if [ -n "$body_file" ]; then
    cat "$body_file"
  else
    printf '%s' "$body"
  fi
}

# POST $2 (a JSON payload) to API path $1 (e.g. "repos/owner/repo/issues"),
# authenticated with a freshly minted App installation token. Prints the
# response's html_url on success; prints the error body to stderr and
# returns 1 on a >=400 response.
gh_app_api_post() {
  local path="$1" payload="$2" token response status body
  token=$(gh_app_token)
  response=$(curl -s -w '\n%{http_code}' -X POST \
    -H "Authorization: token $token" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/${path}" \
    -d "$payload")
  status=$(printf '%s' "$response" | tail -n1)
  body=$(printf '%s' "$response" | sed '$d')
  if [ "$status" -ge 400 ]; then
    echo "GitHub API error ($status):" >&2
    printf '%s\n' "$body" | jq . >&2 2>/dev/null || printf '%s\n' "$body" >&2
    return 1
  fi
  printf '%s' "$body" | jq -r '.html_url'
}

# PATCH $2 (a JSON payload) to API path $1 (e.g. "repos/owner/repo/pulls/42"),
# authenticated with a freshly minted App installation token. Prints the
# response's html_url on success; prints the error body to stderr and
# returns 1 on a >=400 response.
gh_app_api_patch() {
  local path="$1" payload="$2" token response status body
  token=$(gh_app_token)
  response=$(curl -s -w '\n%{http_code}' -X PATCH \
    -H "Authorization: token $token" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/${path}" \
    -d "$payload")
  status=$(printf '%s' "$response" | tail -n1)
  body=$(printf '%s' "$response" | sed '$d')
  if [ "$status" -ge 400 ]; then
    echo "GitHub API error ($status):" >&2
    printf '%s\n' "$body" | jq . >&2 2>/dev/null || printf '%s\n' "$body" >&2
    return 1
  fi
  printf '%s' "$body" | jq -r '.html_url'
}

# GET API path $1 (e.g. "repos/owner/repo/pulls/42"),
# authenticated with a freshly minted App installation token. Prints the
# response JSON on success; prints the error body to stderr and returns 1
# on a >=400 response.
gh_app_api_get() {
  local path="$1" token response status body
  token=$(gh_app_token)
  response=$(curl -s -w '\n%{http_code}' -X GET \
    -H "Authorization: token $token" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/${path}")
  status=$(printf '%s' "$response" | tail -n1)
  body=$(printf '%s' "$response" | sed '$d')
  if [ "$status" -ge 400 ]; then
    echo "GitHub API error ($status):" >&2
    printf '%s\n' "$body" | jq . >&2 2>/dev/null || printf '%s\n' "$body" >&2
    return 1
  fi
  printf '%s' "$body"
}
