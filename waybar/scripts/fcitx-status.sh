#!/usr/bin/env bash

if ! command -v fcitx5-remote >/dev/null 2>&1; then
  echo '{"text":"?","tooltip":"fcitx5-remote not found","class":"fcitx-unknown"}'
  exit 0
fi

if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
fi

im=$(fcitx5-remote -n 2>/dev/null)

case "$im" in
  pinyin)
    echo '{"text":"中","tooltip":"Pinyin","class":"fcitx-cn"}'
    ;;
  rime)
    echo '{"text":"中","tooltip":"Rime","class":"fcitx-cn"}'
    ;;
  keyboard*)
    echo '{"text":"EN","tooltip":"English","class":"fcitx-en"}'
    ;;
  "")
    echo '{"text":"?","tooltip":"No input method","class":"fcitx-unknown"}'
    ;;
  *)
    echo '{"text":"?","tooltip":"Unknown","class":"fcitx-unknown"}'
    ;;
esac
