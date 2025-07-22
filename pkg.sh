#!/usr/bin/env bash

# Pull in the distro ID and family (e.g. "arch", "ubuntu", "fedora")
if [ -f /etc/os-release ]; then
  . /etc/os-release
else
  echo "❌ Cannot detect distro (no /etc/os-release)" >&2
  return 1 2>/dev/null || exit 1
fi

# Decide on the installer based on ID first
case "$ID" in
  arch)
    PKG_INSTALL() { sudo pacman -Syu --noconfirm "$@"; }
    PKG_NAME="pacman"
    ;;
  ubuntu|debian)
    PKG_INSTALL() { sudo apt update && sudo apt install -y "$@"; }
    PKG_NAME="apt"
    ;;
  fedora)
    PKG_INSTALL() { sudo dnf install -y "$@"; }
    PKG_NAME="dnf"
    ;;
  alpine)
    PKG_INSTALL() { sudo apk add "$@"; }
    PKG_NAME="apk"
    ;;
  suse*|opensuse*)
    PKG_INSTALL() { sudo zypper install -y "$@"; }
    PKG_NAME="zypper"
    ;;
  void)
    PKG_INSTALL() { sudo xbps-install -Sy "$@"; }
    PKG_NAME="xbps"
    ;;
  *)
    # Fallback to checking commands if ID wasn’t matched
    if command -v pacman >/dev/null; then
      PKG_INSTALL() { sudo pacman -Syu --noconfirm "$@"; }
      PKG_NAME="pacman"
    elif command -v apt >/dev/null; then
      PKG_INSTALL() { sudo apt update && sudo apt install -y "$@"; }
      PKG_NAME="apt"
    else
      echo "❌ Unsupported distro or missing package manager." >&2
      return 1 2>/dev/null || exit 1
    fi
    ;;
esac

export -f PKG_INSTALL
echo "✅ Using package manager: $PKG_NAME"

