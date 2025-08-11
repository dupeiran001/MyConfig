#!/bin/sh
# This script symlinks the repo's hooks into the .git/hooks directory.

HOOKS_DIR=$(git rev-parse --show-toplevel)/.git/hooks
SCRIPTS_DIR=$(git rev-parse --show-toplevel)/scripts

# Create hooks for decryption
ln -sf "$SCRIPTS_DIR/decrypt-secrets.sh" "$HOOKS_DIR/post-merge"
ln -sf "$SCRIPTS_DIR/decrypt-secrets.sh" "$HOOKS_DIR/post-checkout"
echo "✓ Decryption hooks installed."

# Create hook for pre-push check
ln -sf "$SCRIPTS_DIR/check-secrets.sh" "$HOOKS_DIR/pre-push"
echo "✓ Pre-push check hook installed."

echo "All Git hooks installed successfully!"
