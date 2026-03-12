#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="${0##*/}"

DRY_RUN=false
INTERACTIVE=false
TUI=false
ASSUME_YES=false
LIST_GROUPS=false

declare -a FORCE_ENABLE=()
declare -a FORCE_DISABLE=()

declare -a GROUP_ORDER=(
  core
  session
  audio
  network
  bluetooth
  clipboard
  ime
  telemetry
  power
  wireguard
  media
  updates
  waybar_plugin
  terminals
)

declare -A GROUP_DESC=(
  [core]="Niri + Waybar + launcher + lockscreen basics"
  [session]="Portal + policykit integration for Wayland sessions"
  [audio]="PipeWire/WirePlumber + pactl/wpctl for volume scripts"
  [network]="NetworkManager + iw for Wi-Fi scripts"
  [bluetooth]="Bluetooth control for Waybar Bluetooth menu"
  [clipboard]="wl-clipboard + clipman integration"
  [ime]="Fcitx5 input method integration"
  [telemetry]="turbostat/intel_gpu_top/jq/inotify for CPU+GPU widgets"
  [power]="TLP profile widgets"
  [wireguard]="WireGuard status toggle widget"
  [media]="playerctl for media widget controls"
  [updates]="System update widget dependencies"
  [waybar_plugin]="libniri_taskbar plugin used by your Waybar config"
  [terminals]="Terminal emulators used by your config/scripts"
)

declare -A PKGS_ARCH=(
  [core]="niri waybar rofi mako swaybg swaylock brightnessctl wl-clipboard libnotify"
  [session]="xdg-desktop-portal xdg-desktop-portal-wlr polkit-gnome"
  [audio]="pipewire pipewire-pulse wireplumber"
  [network]="networkmanager iw"
  [bluetooth]="bluez bluez-utils"
  [clipboard]="clipman"
  [ime]="fcitx5 fcitx5-gtk fcitx5-qt"
  [telemetry]="turbostat intel-gpu-tools jq inotify-tools"
  [power]="tlp"
  [wireguard]="wireguard-tools"
  [media]="playerctl"
  [updates]="pacman-contrib flatpak paru|yay"
  [waybar_plugin]="waybar-niri-taskbar"
  [terminals]="wezterm kitty"
)

declare -A PKGS_FEDORA=(
  [core]="niri waybar rofi-wayland|rofi mako swaybg swaylock brightnessctl wl-clipboard libnotify"
  [session]="xdg-desktop-portal xdg-desktop-portal-wlr lxqt-policykit|polkit-gnome"
  [audio]="pipewire pipewire-pulseaudio wireplumber pulseaudio-utils"
  [network]="NetworkManager iw"
  [bluetooth]="bluez bluez-tools"
  [clipboard]="clipman|wl-clipboard"
  [ime]="fcitx5 fcitx5-gtk fcitx5-qt5|fcitx5-qt"
  [telemetry]="kernel-tools intel-gpu-tools jq inotify-tools"
  [power]="tlp"
  [wireguard]="wireguard-tools"
  [media]="playerctl"
  [updates]="dnf-plugins-core flatpak"
  [waybar_plugin]=""
  [terminals]="wezterm kitty"
)

declare -A PKGS_DEBIAN=(
  [core]="niri waybar rofi-wayland|rofi mako-notifier|mako swaybg swaylock brightnessctl wl-clipboard libnotify-bin"
  [session]="xdg-desktop-portal xdg-desktop-portal-wlr policykit-1-gnome"
  [audio]="pipewire pipewire-pulse wireplumber pulseaudio-utils"
  [network]="network-manager iw"
  [bluetooth]="bluez"
  [clipboard]="clipman|wl-clipboard"
  [ime]="fcitx5 fcitx5-frontend-gtk3|fcitx5-gtk fcitx5-frontend-qt5|fcitx5-qt"
  [telemetry]="linux-tools-common intel-gpu-tools jq inotify-tools"
  [power]="tlp"
  [wireguard]="wireguard-tools"
  [media]="playerctl"
  [updates]="flatpak"
  [waybar_plugin]=""
  [terminals]="wezterm|kitty kitty"
)

declare -A DEFAULT_ENABLED=(
  [core]=1
  [session]=1
  [audio]=1
  [network]=1
  [bluetooth]=1
  [clipboard]=1
  [ime]=1
  [telemetry]=1
  [power]=1
  [wireguard]=1
  [media]=1
  [updates]=1
  [waybar_plugin]=1
  [terminals]=1
)

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<EOF_USAGE
Usage: $SCRIPT_NAME [options]

Install dependencies used by your ~/.config (niri/waybar/rofi stack).

Options:
  --tui                    Use checklist TUI to select groups/packages.
  --interactive            Prompt per group in plain text mode.
  --dry-run                Print what would be installed.
  --yes                    Non-interactive package-manager confirmation.
  --with g1,g2             Force-enable groups (comma-separated).
  --without g1,g2          Force-disable groups (comma-separated).
  --list-groups            Show available groups and exit.
  -h, --help               Show this help and exit.

Examples:
  $SCRIPT_NAME --tui
  $SCRIPT_NAME --dry-run --without telemetry,waybar_plugin
  $SCRIPT_NAME --with core,session,audio,network
EOF_USAGE
}

split_csv_into_array() {
  local csv=$1
  local -n out_ref=$2
  local item
  IFS=',' read -r -a out_ref <<< "$csv"
  for item in "${out_ref[@]}"; do
    [[ -n "$item" ]] || die "Invalid empty value in comma-separated list: $csv"
  done
}

declare DISTRO=""
declare ID_LIKE_VAL=""
declare PKG_SYSTEM=""
declare -a SUDO_CMD=()
declare TUI_BACKEND=""
declare aur_helper=""

detect_distro() {
  [[ -f /etc/os-release ]] || die "/etc/os-release not found"
  # shellcheck disable=SC1091
  source /etc/os-release
  DISTRO=${ID:-}
  ID_LIKE_VAL=${ID_LIKE:-}
  [[ -n "$DISTRO" ]] || die "Could not detect distro ID"
}

pkg_system_for_distro() {
  case "$DISTRO" in
    arch) echo "arch" ;;
    fedora) echo "fedora" ;;
    ubuntu|debian) echo "debian" ;;
    *)
      if [[ "$ID_LIKE_VAL" == *"arch"* ]]; then
        echo "arch"
      elif [[ "$ID_LIKE_VAL" == *"fedora"* || "$ID_LIKE_VAL" == *"rhel"* ]]; then
        echo "fedora"
      elif [[ "$ID_LIKE_VAL" == *"debian"* || "$ID_LIKE_VAL" == *"ubuntu"* ]]; then
        echo "debian"
      else
        die "Unsupported distro: ID=$DISTRO ID_LIKE=$ID_LIKE_VAL"
      fi
      ;;
  esac
}

set_sudo_cmd() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    SUDO_CMD=()
    return 0
  fi
  command -v sudo >/dev/null 2>&1 || die "sudo is required to install packages"
  SUDO_CMD=(sudo)
}

run_cmd() {
  if $DRY_RUN; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

valid_group() {
  local g=$1
  [[ -n "${GROUP_DESC[$g]:-}" ]]
}

show_groups() {
  log "Available groups:"
  local g
  for g in "${GROUP_ORDER[@]}"; do
    printf '  %-14s %s\n' "$g" "${GROUP_DESC[$g]}"
  done
}

declare -A GROUP_ENABLED=()
initialize_group_selection() {
  local g
  for g in "${GROUP_ORDER[@]}"; do
    GROUP_ENABLED["$g"]=${DEFAULT_ENABLED["$g"]}
  done
}

apply_group_overrides() {
  local g
  for g in "${FORCE_ENABLE[@]}"; do
    valid_group "$g" || die "Unknown group in --with: $g"
    GROUP_ENABLED["$g"]=1
  done
  for g in "${FORCE_DISABLE[@]}"; do
    valid_group "$g" || die "Unknown group in --without: $g"
    GROUP_ENABLED["$g"]=0
  done
}

prompt_yes_no() {
  local prompt=$1
  local default_yes=$2
  local ans=""
  while true; do
    if [[ "$default_yes" == "1" ]]; then
      read -r -p "$prompt [Y/n] " ans
    else
      read -r -p "$prompt [y/N] " ans
    fi
    ans=${ans,,}
    if [[ -z "$ans" ]]; then
      [[ "$default_yes" == "1" ]] && return 0 || return 1
    fi
    case "$ans" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
      *) ;;
    esac
  done
}

declare -A PARU_EXPLICIT_SET=()
load_paru_explicit_set_if_available() {
  if [[ "$PKG_SYSTEM" != "arch" ]]; then
    return 0
  fi
  command -v paru >/dev/null 2>&1 || return 0
  local p
  while read -r p; do
    [[ -n "$p" ]] || continue
    PARU_EXPLICIT_SET["$p"]=1
  done < <(paru -Qqe 2>/dev/null || true)
}

group_pkg_specs_for_system() {
  local group=$1
  case "$PKG_SYSTEM" in
    arch) echo "${PKGS_ARCH[$group]:-}" ;;
    fedora) echo "${PKGS_FEDORA[$group]:-}" ;;
    debian) echo "${PKGS_DEBIAN[$group]:-}" ;;
    *) die "Internal error: unknown package system $PKG_SYSTEM" ;;
  esac
}

group_installed_hint_arch() {
  local group=$1
  local specs spec
  local -a hits=()
  specs="$(group_pkg_specs_for_system "$group")"
  for spec in $specs; do
    local -a cand=()
    IFS='|' read -r -a cand <<< "$spec"
    local c
    for c in "${cand[@]}"; do
      if [[ -n "${PARU_EXPLICIT_SET[$c]:-}" ]]; then
        hits+=("$c")
        break
      fi
    done
  done
  if [[ ${#hits[@]} -gt 0 ]]; then
    printf '%s' "${hits[*]}"
  fi
}

interactive_group_selection() {
  log "Interactive group selection:"
  local g default hint prompt
  for g in "${GROUP_ORDER[@]}"; do
    default=${GROUP_ENABLED[$g]}
    hint=""
    if [[ "$PKG_SYSTEM" == "arch" ]]; then
      hint="$(group_installed_hint_arch "$g")"
    fi
    prompt="$g - ${GROUP_DESC[$g]}"
    if [[ -n "$hint" ]]; then
      prompt+=" (installed via paru: $hint)"
    fi
    if prompt_yes_no "$prompt" "$default"; then
      GROUP_ENABLED["$g"]=1
    else
      GROUP_ENABLED["$g"]=0
    fi
  done
}

pkg_installed() {
  local pkg=$1
  case "$PKG_SYSTEM" in
    arch) pacman -Q "$pkg" >/dev/null 2>&1 ;;
    fedora) rpm -q "$pkg" >/dev/null 2>&1 ;;
    debian) dpkg -s "$pkg" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

pkg_in_repo() {
  local pkg=$1
  case "$PKG_SYSTEM" in
    arch) pacman -Si "$pkg" >/dev/null 2>&1 ;;
    fedora) dnf info -q "$pkg" >/dev/null 2>&1 ;;
    debian) apt-cache show "$pkg" 2>/dev/null | grep -q '^Package:' ;;
    *) return 1 ;;
  esac
}

detect_aur_helper() {
  if [[ "$PKG_SYSTEM" != "arch" ]]; then
    return 0
  fi
  if command -v paru >/dev/null 2>&1; then
    aur_helper="paru"
  elif command -v yay >/dev/null 2>&1; then
    aur_helper="yay"
  fi
}

install_pkg_arch() {
  local pkg=$1
  local -a pacman_flags=(--needed)
  local -a aur_flags=(--needed)
  $ASSUME_YES && pacman_flags+=(--noconfirm) && aur_flags+=(--noconfirm)

  if pkg_installed "$pkg"; then
    log "Already installed: $pkg"
    return 0
  fi

  if pkg_in_repo "$pkg"; then
    run_cmd "${SUDO_CMD[@]}" pacman -S "${pacman_flags[@]}" "$pkg"
    return 0
  fi

  if [[ -n "$aur_helper" ]]; then
    run_cmd "$aur_helper" -S "${aur_flags[@]}" "$pkg"
    return 0
  fi

  warn "Package not found in pacman repos and no AUR helper available: $pkg"
}

install_pkg_fedora() {
  local pkg=$1
  local -a dnf_flags=()
  $ASSUME_YES && dnf_flags=(-y)

  if pkg_installed "$pkg"; then
    log "Already installed: $pkg"
    return 0
  fi

  if pkg_in_repo "$pkg"; then
    run_cmd "${SUDO_CMD[@]}" dnf install "${dnf_flags[@]}" "$pkg"
  else
    warn "Package not available in dnf repos: $pkg"
  fi
}

install_pkg_debian() {
  local pkg=$1
  local -a apt_flags=()
  $ASSUME_YES && apt_flags=(-y)

  if pkg_installed "$pkg"; then
    log "Already installed: $pkg"
    return 0
  fi

  if pkg_in_repo "$pkg"; then
    run_cmd "${SUDO_CMD[@]}" apt-get install "${apt_flags[@]}" "$pkg"
  else
    warn "Package not available in apt repos: $pkg"
  fi
}

choose_candidate_from_spec() {
  local spec=$1
  local -a candidates=()
  IFS='|' read -r -a candidates <<< "$spec"
  local c
  for c in "${candidates[@]}"; do
    if pkg_installed "$c"; then
      echo "$c"
      return 0
    fi
  done
  for c in "${candidates[@]}"; do
    if pkg_in_repo "$c"; then
      echo "$c"
      return 0
    fi
  done
  if [[ "$PKG_SYSTEM" == "arch" && -n "$aur_helper" ]]; then
    echo "${candidates[0]}"
    return 0
  fi
  return 1
}

collect_selected_specs() {
  local -n out_specs=$1
  local g specs spec
  for g in "${GROUP_ORDER[@]}"; do
    [[ "${GROUP_ENABLED[$g]}" == "1" ]] || continue
    specs="$(group_pkg_specs_for_system "$g")"
    [[ -n "$specs" ]] || continue
    for spec in $specs; do
      out_specs+=("$spec")
    done
  done
}

dedupe_array() {
  local -n in_arr=$1
  local -n out_arr=$2
  declare -A seen=()
  local item
  for item in "${in_arr[@]}"; do
    [[ -n "${seen[$item]:-}" ]] && continue
    seen["$item"]=1
    out_arr+=("$item")
  done
}

print_selection_summary() {
  log ""
  log "Selected groups:"
  local g
  for g in "${GROUP_ORDER[@]}"; do
    if [[ "${GROUP_ENABLED[$g]}" == "1" ]]; then
      printf '  [x] %-14s %s\n' "$g" "${GROUP_DESC[$g]}"
    else
      printf '  [ ] %-14s %s\n' "$g" "${GROUP_DESC[$g]}"
    fi
  done
}

detect_tui_backend() {
  if command -v whiptail >/dev/null 2>&1; then
    TUI_BACKEND="whiptail"
  elif command -v dialog >/dev/null 2>&1; then
    TUI_BACKEND="dialog"
  else
    die "--tui requested but neither whiptail nor dialog is installed"
  fi
}

tui_checklist() {
  local title=$1
  local text=$2
  local height=$3
  local width=$4
  local list_height=$5
  shift 5
  local output=""
  if [[ "$TUI_BACKEND" == "whiptail" ]]; then
    output=$(whiptail --title "$title" --checklist "$text" "$height" "$width" "$list_height" "$@" 3>&1 1>&2 2>&3) || return 1
  else
    output=$(dialog --stdout --separate-output --title "$title" --checklist "$text" "$height" "$width" "$list_height" "$@") || return 1
  fi
  printf '%s' "$output"
}

parse_tui_choices() {
  local raw=$1
  local -n out_ref=$2
  out_ref=()
  [[ -n "$raw" ]] || return 0
  if [[ "$TUI_BACKEND" == "whiptail" ]]; then
    raw=${raw//\"/}
    read -r -a out_ref <<< "$raw"
  else
    while read -r line; do
      [[ -n "$line" ]] || continue
      out_ref+=("$line")
    done <<< "$raw"
  fi
}

tui_yesno() {
  local title=$1
  local text=$2
  if [[ "$TUI_BACKEND" == "whiptail" ]]; then
    whiptail --title "$title" --yesno "$text" 16 78
  else
    dialog --title "$title" --yesno "$text" 16 78
  fi
}

tui_group_selection() {
  local -a options=()
  local g state hint desc
  for g in "${GROUP_ORDER[@]}"; do
    if [[ "${GROUP_ENABLED[$g]}" == "1" ]]; then
      state="ON"
    else
      state="OFF"
    fi
    desc="${GROUP_DESC[$g]}"
    if [[ "$PKG_SYSTEM" == "arch" ]]; then
      hint="$(group_installed_hint_arch "$g")"
      if [[ -n "$hint" ]]; then
        desc+=" [paru: $hint]"
      fi
    fi
    options+=("$g" "$desc" "$state")
  done

  local raw=""
  raw="$(tui_checklist \
    "Config Dependency Groups" \
    "Select feature groups to include." \
    26 120 16 \
    "${options[@]}")" || die "Group selection cancelled"

  local -a selected=()
  parse_tui_choices "$raw" selected

  local g2
  for g2 in "${GROUP_ORDER[@]}"; do
    GROUP_ENABLED["$g2"]=0
  done
  for g2 in "${selected[@]}"; do
    valid_group "$g2" || continue
    GROUP_ENABLED["$g2"]=1
  done
}

build_package_list_for_selected_groups() {
  local -n out_pkgs=$1
  local -a all_specs=()
  local -a unique_specs=()
  local -a candidates=()

  collect_selected_specs all_specs
  dedupe_array all_specs unique_specs

  local spec selected
  for spec in "${unique_specs[@]}"; do
    if selected="$(choose_candidate_from_spec "$spec")"; then
      candidates+=("$selected")
    else
      warn "No installable candidate found for spec: $spec"
    fi
  done

  out_pkgs=()
  dedupe_array candidates out_pkgs
}

tui_package_selection() {
  local -n in_pkgs=$1
  local -n out_pkgs=$2
  local -a options=()
  local pkg desc state

  for pkg in "${in_pkgs[@]}"; do
    if pkg_installed "$pkg"; then
      desc="already installed"
      state="OFF"
    else
      desc="not installed"
      state="ON"
    fi
    options+=("$pkg" "$desc" "$state")
  done

  local raw=""
  raw="$(tui_checklist \
    "Package Selection" \
    "Select packages to install." \
    26 100 16 \
    "${options[@]}")" || die "Package selection cancelled"

  parse_tui_choices "$raw" out_pkgs
}

parse_args() {
  local arg
  while [[ $# -gt 0 ]]; do
    arg=$1
    case "$arg" in
      --tui) TUI=true ;;
      --interactive) INTERACTIVE=true ;;
      --dry-run) DRY_RUN=true ;;
      --yes) ASSUME_YES=true ;;
      --list-groups) LIST_GROUPS=true ;;
      --with)
        [[ $# -ge 2 ]] || die "--with requires a comma-separated argument"
        local -a tmp=()
        split_csv_into_array "$2" tmp
        FORCE_ENABLE+=("${tmp[@]}")
        shift
        ;;
      --without)
        [[ $# -ge 2 ]] || die "--without requires a comma-separated argument"
        local -a tmp=()
        split_csv_into_array "$2" tmp
        FORCE_DISABLE+=("${tmp[@]}")
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $arg (use --help)"
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"
  detect_distro
  PKG_SYSTEM="$(pkg_system_for_distro)"
  detect_aur_helper
  load_paru_explicit_set_if_available

  if $LIST_GROUPS; then
    show_groups
    exit 0
  fi

  if $TUI; then
    [[ -t 0 && -t 1 ]] || die "--tui requires an interactive terminal (tty)"
    detect_tui_backend
  fi

  initialize_group_selection
  apply_group_overrides

  if $TUI; then
    tui_group_selection
  elif $INTERACTIVE; then
    interactive_group_selection
  fi

  print_selection_summary

  local -a resolved_pkgs=()
  build_package_list_for_selected_groups resolved_pkgs

  if [[ ${#resolved_pkgs[@]} -eq 0 ]]; then
    warn "No packages selected for installation"
    exit 0
  fi

  local -a final_pkgs=()
  if $TUI; then
    tui_package_selection resolved_pkgs final_pkgs
  else
    final_pkgs=("${resolved_pkgs[@]}")
  fi

  if [[ ${#final_pkgs[@]} -eq 0 ]]; then
    warn "No packages selected in package step"
    exit 0
  fi

  set_sudo_cmd

  log ""
  log "Distro detected: $DISTRO (package system: $PKG_SYSTEM)"
  log "Packages selected (${#final_pkgs[@]}):"
  printf '  %s\n' "${final_pkgs[@]}"
  log ""

  if ! $DRY_RUN && ! $ASSUME_YES; then
    if $TUI; then
      tui_yesno "Confirm Installation" "Proceed with installing ${#final_pkgs[@]} package(s)?" || {
        log "Cancelled."
        exit 0
      }
    else
      prompt_yes_no "Proceed with installation?" 1 || {
        log "Cancelled."
        exit 0
      }
    fi
  fi

  local pkg
  for pkg in "${final_pkgs[@]}"; do
    case "$PKG_SYSTEM" in
      arch) install_pkg_arch "$pkg" ;;
      fedora) install_pkg_fedora "$pkg" ;;
      debian) install_pkg_debian "$pkg" ;;
      *) die "Internal error: unknown package system $PKG_SYSTEM" ;;
    esac
  done

  log ""
  log "Done."
}

main "$@"
