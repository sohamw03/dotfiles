#!/usr/bin/env bash
set -euo pipefail

src_base="$HOME/dotfiles/arch_local_share_applications"
dst_base="$HOME/.local/share/applications"

# Ensure destination directory exists
mkdir -p -- "$dst_base"

# Iterate over .desktop files in the source base
find "$src_base" -mindepth 1 -maxdepth 1 -type f -name "*.desktop" -print0 | while IFS= read -r -d '' src_file; do
  name="$(basename "$src_file")"
  dst="$dst_base/$name"

  # Remove existing target (file or symlink)
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rm -f -- "$dst"
  fi

  # Create symlink
  ln -sfn -- "$src_file" "$dst"
  echo "Linked: $dst -> $src_file"
done