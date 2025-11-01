#!/bin/bash
# This script copies desktop files to the local applications directory and updates the desktop database.

# Set the source and destination directories
SOURCE_DIR="$(dirname "$0")"
DEST_DIR="$HOME/.local/share/applications"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy all .desktop files from the source directory to the destination directory
for file in "$SOURCE_DIR"/*.desktop; do
  cp "$file" "$DEST_DIR"
done

# Refresh the desktop database
update-desktop-database "$DEST_DIR"

echo "Desktop entries installed and database updated."
