#!/bin/bash
# Output notch spacer on Apple Silicon (with show_notch=1), or distro icon otherwise
if grep -q "appledrm.show_notch=1" /proc/cmdline 2>/dev/null; then
    echo '{"text": " ", "class": "notch"}'
else
    echo '{"text": " ", "class": "normal"}'
fi
