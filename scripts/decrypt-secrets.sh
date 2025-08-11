#!/bin/sh
# This script decrypts secrets using age.

# --- Configuration ---
SECRETS_DIR=$(git rev-parse --show-toplevel)
ENCRYPTED_FILE="$SECRETS_DIR/.local.sh.age"
DECRYPTED_FILE="$SECRETS_DIR/.local.sh"
RECIPIENTS_FILE="$SECRETS_DIR/recipients.txt"
# Use the default SSH key for decryption
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# --- Main Logic ---
# Exit if age is not installed
if ! command -v age >/dev/null; then
  echo "›› age command not found. Skipping decryption."
  exit 0
fi

# Check if the necessary files exist
if [ ! -f "$ENCRYPTED_FILE" ]; then
  echo "›› No encrypted file found at $ENCRYPTED_FILE. Nothing to do."
  exit 0
fi

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "›› SSH private key not found at $SSH_KEY_PATH. Cannot decrypt."
  exit 1
fi

echo "✓ Decrypting secrets..."
age -d -i "$SSH_KEY_PATH" -o "$DECRYPTED_FILE" "$ENCRYPTED_FILE"

if [ $? -eq 0 ]; then
  echo "Secrets successfully decrypted to $DECRYPTED_FILE"
else
  echo "✗ Error: Failed to decrypt secrets."
  exit 1
fi
