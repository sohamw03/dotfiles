#!/usr/bin/env bash
set -euo pipefail

src_base="$HOME/dotfiles/arch.config"
dst_base="$HOME/.config"

# Iterate over directories in the source base
find "$src_base" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' src_dir; do
  name="$(basename "$src_dir")"
  dst="$dst_base/$name"

  # Remove existing target (file, dir, or symlink)
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rm -rf -- "$dst"  # cautious but necessary when replacing whole trees
  fi

  # Ensure parent exists
  mkdir -p -- "$dst_base"

  # Create symlink
  ln -sfn -- "$src_dir" "$dst"
  echo "Linked: $dst -> $src_dir"
done

# Link .toml files, removing existing ones first
for src_file in "$src_base"/*.toml; do
  [ -e "$src_file" ] || continue
  name="$(basename "$src_file")"
  dst="$dst_base/$name"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rm -f -- "$dst"
  fi

  ln -sfn -- "$src_file" "$dst"
  echo "Linked: $dst -> $src_file"
done
