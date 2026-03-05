#!/usr/bin/env bash
# Install custom drun entries for rofi.

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

mkdir -p "$DEST_DIR"

for file in "$SOURCE_DIR"/*.desktop; do
  [ -f "$file" ] || continue
  install -m 0644 "$file" "$DEST_DIR/$(basename "$file")"
done

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DEST_DIR" >/dev/null 2>&1 || true
fi

echo "Installed custom desktop entries to $DEST_DIR"
