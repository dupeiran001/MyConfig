#!/usr/bin/env bash

set -euo pipefail

ROOT="${ROFI_RECURSIVE_ROOT:-$HOME}"

selection="${1:-}"
LAUNCH_LABEL="Open recursive fzf browser (home)"

if [[ "${ROFI_RETV:-0}" -eq 0 ]]; then
    printf '\0prompt\x1fRecursive Files\n'
    printf '\0message\x1fPress Enter to open terminal fzf browser rooted at %s\n' "$ROOT"
    printf '%s\n' "$LAUNCH_LABEL"
    exit 0
fi

if [[ "${ROFI_RETV:-0}" -eq 1 && "$selection" == "$LAUNCH_LABEL" ]]; then
    # Run true interactive fzf in a terminal, then open the chosen path.
    rofi-sensible-terminal -e bash -lc '
        root="$1"
        sel="$(
            fzf \
                --walker file,dir \
                --walker-root "$root" \
                --walker-skip .git,node_modules,target,.cache \
                --scheme path \
                --height 100%
        )"
        [[ -n "$sel" ]] && xdg-open "$sel" >/dev/null 2>&1 &
    ' bash "$ROOT" >/dev/null 2>&1 &
fi
