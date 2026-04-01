#!/bin/bash
# Output arrow glyph or empty string based on notch detection
# Usage: notch-arrow.sh <arrow_char>
ARROW="$1"
if grep -q "appledrm.show_notch=1" /proc/cmdline 2>/dev/null; then
    echo '{"text": "", "class": "notch"}'
else
    echo "{\"text\": \"${ARROW}\", \"class\": \"normal\"}"
fi
