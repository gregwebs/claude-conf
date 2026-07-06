#!/usr/bin/env bash
# Shared lib: mint a short-lived GitHub App installation access token.
# Sourced by credential-helper.sh and the gh-app-*.sh scripts in this directory.
#
# Only two secrets are needed, read from $GITHUB_APP_SECRETS_DIR (default
# ~/.config/github-app, not tracked in this repo, chmod 700 with 600 files):
#   - client-id       the App's client ID (used as the JWT `iss` claim)
#   - private-key.pem the App's private key (signs the JWT)
# The installation ID is not a secret (it's just an opaque identifier for
# this repo's installation of the App) and is committed alongside this
# script as ./installation-id.

_gh_app_b64url() {
  openssl base64 -A | tr '+/' '-_' | tr -d '='
}

gh_app_token() {
  local secrets_dir script_dir client_id installation_id
  secrets_dir="${GITHUB_APP_SECRETS_DIR:-$HOME/.config/github-app}"
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  client_id=$(cat "$secrets_dir/client-id")
  installation_id=$(cat "$GITHUB_APP_SECRETS_DIR/installation-id")

  local now iat exp header claims signing_input signature jwt
  now=$(date +%s)
  iat=$((now - 60))
  exp=$((now + 540))
  header=$(printf '{"alg":"RS256","typ":"JWT"}' | _gh_app_b64url)
  claims=$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "$iat" "$exp" "$client_id" | _gh_app_b64url)
  signing_input="${header}.${claims}"
  signature=$(printf '%s' "$signing_input" | openssl dgst -sha256 -sign "$secrets_dir/private-key.pem" | _gh_app_b64url)
  jwt="${signing_input}.${signature}"

  local token
  token=$(curl -sf -X POST \
    -H "Authorization: Bearer $jwt" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/app/installations/${installation_id}/access_tokens" \
    | jq -r .token)

  if [ -z "$token" ] || [ "$token" = "null" ]; then
    echo "gh-app-token: failed to obtain installation access token" >&2
    return 1
  fi

  printf '%s' "$token"
}
