#!/bin/sh
# This script verifies that the encrypted secrets file is up-to-date.

# --- Configuration ---
SECRETS_DIR=$(git rev-parse --show-toplevel)
ENCRYPTED_FILE="$SECRETS_DIR/.local.sh.age"
DECRYPTED_FILE="$SECRETS_DIR/.local.sh"
RECIPIENTS_FILE="$SECRETS_DIR/recipients.txt"

# --- Main Logic ---
# If there's no local decrypted file, there's nothing to check.
if [ ! -f "$DECRYPTED_FILE" ]; then
  exit 0
fi

# Decrypt the current version to a temporary file for comparison
TEMP_DECRYPTED=$(mktemp)
# Clean up the temp file on exit
trap 'rm -f "$TEMP_DECRYPTED"' EXIT

# Decrypt silently for the check
age -d -i "$HOME/.ssh/id_rsa" -o "$TEMP_DECRYPTED" "$ENCRYPTED_FILE" 2>/dev/null

# Compare the current secrets file with what's encrypted
if diff -q "$DECRYPTED_FILE" "$TEMP_DECRYPTED" >/dev/null; then
  # Files are the same, proceed with push
  exit 0
else
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "✗ PUSH REJECTED: Your local secrets file has changed."
  echo "  The encrypted version is out of date."
  echo ""
  echo "  To fix this, run these commands:"
  echo ""
  echo "  # Step 1: Re-encrypt your secrets"
  echo "  age -R \"$RECIPIENTS_FILE\" -o \"$ENCRYPTED_FILE\" \"$DECRYPTED_FILE\""
  echo ""
  echo "  # Step 2: Add and commit the updated encrypted file"
  echo "  git add \"$ENCRYPTED_FILE\""
  echo "  git commit -m \"chore: Update secrets\""
  echo ""
  echo "  # Step 3: Try your push again"
  echo "  git push"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  exit 1
fi
