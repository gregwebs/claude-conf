#!/usr/bin/env bash
# Install this repository's platform-specific agent definitions as individual links.
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_SOURCE_DIR="$REPOSITORY_ROOT/agents"
CODEX_SOURCE_DIR="$REPOSITORY_ROOT/.codex/agents"
CLAUDE_INSTALL_DIR="${HOME}/.claude/agents"
CODEX_INSTALL_DIR="${HOME}/.codex/agents"
FORCE=false
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: ./scripts/install-agents.sh [options]

Symlink this repository's Claude and Codex agent definitions into their
respective user agent directories.

Options:
  --dry-run                    Print planned filesystem operations without changing anything.
  --force                      Back up conflicting destination entries, then install links.
  --claude-source-dir DIR      Override agents/.
  --codex-source-dir DIR       Override .codex/agents/.
  --claude-install-dir DIR     Override ~/.claude/agents/.
  --codex-install-dir DIR      Override ~/.codex/agents/.
  -h, --help                   Print this help text.
EOF
}

die() {
  echo "install-agents: $*" >&2
  exit 1
}

run() {
  if "$DRY_RUN"; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    --claude-source-dir)
      [ "$#" -ge 2 ] || die '--claude-source-dir requires a directory'
      CLAUDE_SOURCE_DIR="$2"
      shift
      ;;
    --codex-source-dir)
      [ "$#" -ge 2 ] || die '--codex-source-dir requires a directory'
      CODEX_SOURCE_DIR="$2"
      shift
      ;;
    --claude-install-dir)
      [ "$#" -ge 2 ] || die '--claude-install-dir requires a directory'
      CLAUDE_INSTALL_DIR="$2"
      shift
      ;;
    --codex-install-dir)
      [ "$#" -ge 2 ] || die '--codex-install-dir requires a directory'
      CODEX_INSTALL_DIR="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) die "unknown option: $1" ;;
  esac
  shift
done

discover_agents() {
  local source_dir="$1" extension="$2" platform="$3" candidate
  local -n agents="$4"

  [ -d "$source_dir" ] || die "$platform source directory does not exist: $source_dir"
  source_dir="$(cd "$source_dir" && pwd -P)"
  shopt -s nullglob
  for candidate in "$source_dir"/*."$extension"; do
    [ -f "$candidate" ] && agents+=("$candidate")
  done
  shopt -u nullglob
  [ "${#agents[@]}" -gt 0 ] || die "no $platform .$extension agent files found in: $source_dir"
}

preflight_target() {
  local source="$1" target="$2"

  if [ -e "$target" ] || [ -L "$target" ]; then
    [ "$target" -ef "$source" ] && return
    "$FORCE" || die "refusing to replace existing agent link: $target (rerun with --force)"
  fi
}

backup_path() {
  local target="$1" candidate suffix=1

  candidate="$target.backup.$(date +%Y%m%d%H%M%S)"
  while [ -e "$candidate" ] || [ -L "$candidate" ]; do
    candidate="$target.backup.$(date +%Y%m%d%H%M%S).$suffix"
    suffix=$((suffix + 1))
  done
  printf '%s\n' "$candidate"
}

install_agent() {
  local source="$1" destination="$2" target backup

  target="$destination/$(basename "$source")"
  if [ -e "$target" ] || [ -L "$target" ]; then
    [ "$target" -ef "$source" ] && return
    backup="$(backup_path "$target")"
    run mv "$target" "$backup"
    if "$DRY_RUN"; then
      echo "Would back up $target to $backup" >&2
    else
      echo "Backed up $target to $backup" >&2
    fi
  fi
  run ln -s "$source" "$target"
}

declare -a claude_agents=()
declare -a codex_agents=()
discover_agents "$CLAUDE_SOURCE_DIR" md Claude claude_agents
discover_agents "$CODEX_SOURCE_DIR" toml Codex codex_agents

for source in "${claude_agents[@]}"; do
  preflight_target "$source" "$CLAUDE_INSTALL_DIR/$(basename "$source")"
done
for source in "${codex_agents[@]}"; do
  preflight_target "$source" "$CODEX_INSTALL_DIR/$(basename "$source")"
done

run mkdir -p "$CLAUDE_INSTALL_DIR"
run mkdir -p "$CODEX_INSTALL_DIR"
for source in "${claude_agents[@]}"; do
  install_agent "$source" "$CLAUDE_INSTALL_DIR"
done
for source in "${codex_agents[@]}"; do
  install_agent "$source" "$CODEX_INSTALL_DIR"
done

if "$DRY_RUN"; then
  echo "Dry run complete for $CLAUDE_INSTALL_DIR and $CODEX_INSTALL_DIR"
else
  echo "Installed agent links in $CLAUDE_INSTALL_DIR and $CODEX_INSTALL_DIR"
fi
