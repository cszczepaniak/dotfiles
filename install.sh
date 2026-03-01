#!/usr/bin/env bash
# Symlink dotfiles from this repo into $HOME.
# Existing files/dirs are moved to *.bak (or *.bak.<timestamp> if *.bak exists).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_ROOT="${HOME:?}"

# Paths to link (relative to repo root). Add new files here.
LINK_PATHS=(
  .zshrc
  .tmux.conf
  .config/starship.toml
)

# Resolve to absolute path; works even if the path doesn't exist (uses parent dir)
normalize_path() {
  local path="$1"
  local parent base
  parent="$(dirname "$path")"
  base="$(basename "$path")"
  if [[ -d "$parent" ]]; then
    echo "$(cd "$parent" && pwd)/$base"
  else
    echo "$path"
  fi
}

link_one() {
  local rel_path="$1"
  local src="$REPO_ROOT/$rel_path"
  local dest="$HOME_ROOT/$rel_path"

  if [[ ! -e "$src" ]]; then
    echo "  skip (missing in repo): $rel_path"
    return
  fi

  if [[ -L "$dest" ]]; then
    local dest_target
    dest_target=$(readlink "$dest")
    # Resolve relative symlink target for comparison
    if [[ "$dest_target" != /* ]]; then
      dest_target="$(cd "$(dirname "$dest")" && cd "$(dirname "$dest_target")" && pwd)/$(basename "$dest_target")"
    fi
    if [[ "$(normalize_path "$dest_target")" == "$(normalize_path "$src")" ]]; then
      echo "  ok (already linked): $rel_path"
      return
    fi
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="$dest.bak"
    if [[ -e "$backup" || -L "$backup" ]]; then
      backup="$dest.bak.$(date +%s)"
    fi
    echo "  backup: $rel_path -> $(basename "$backup")"
    mv "$dest" "$backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  link: $rel_path"
}

main() {
  echo "Linking dotfiles from $REPO_ROOT into $HOME_ROOT"
  for rel in "${LINK_PATHS[@]}"; do
    link_one "$rel"
  done
  echo "Done."
}

main "$@"
