#!/usr/bin/env bash
# dotfiles installer — works on Debian/Raspberry Pi OS (apt) and Arch/Manjaro (pacman)
#
#   ./install.sh            everything: packages + tools + link configs + nvim config
#   ./install.sh packages   only system packages and extra tools
#   ./install.sh link       only link configs and hook them into the shell
#   ./install.sh nvim       only clone the nvim config
#
# Safe to run again: installed things are skipped.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_REPO="https://github.com/CarlJar/nvim_cj"
NVIM_MIN="0.11"
BIN="$HOME/.local/bin"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---------- detect system ----------
if have apt-get; then
  PM=apt
elif have pacman; then
  PM=pacman
else
  die "neither apt nor pacman found — unsupported system"
fi

case "$(uname -m)" in
  aarch64|arm64) ARCH=aarch64; ARCH_ALT=arm64 ;;
  x86_64|amd64)  ARCH=x86_64;  ARCH_ALT=amd64 ;;
  *) die "unsupported CPU architecture: $(uname -m)" ;;
esac

# read a package list, dropping comments and blank lines
read_list() { sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$' || true; }

# ---------- GitHub releases ----------
# latest release asset URL of <owner/repo> whose name matches <regex>
gh_asset_url() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep -o '"browser_download_url": *"[^"]*"' \
    | cut -d'"' -f4 \
    | grep -Ei "$2" \
    | head -n1
}

# download a release archive and put the named binaries into ~/.local/bin
install_from_release() {
  local repo=$1 regex=$2; shift 2
  local url tmp f b
  url=$(gh_asset_url "$repo" "$regex") || true
  [ -n "$url" ] || { warn "no release asset for $repo matching '$regex'"; return 1; }
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/archive" "$url"
  mkdir -p "$tmp/x" "$BIN"
  case "$url" in
    *.zip)           unzip -q "$tmp/archive" -d "$tmp/x" ;;
    *.tar.gz|*.tgz)  tar -xzf "$tmp/archive" -C "$tmp/x" ;;
    *) rm -rf "$tmp"; warn "unknown archive type: $url"; return 1 ;;
  esac
  for b in "$@"; do
    f=$(find "$tmp/x" -type f -name "$b" | head -n1)
    [ -n "$f" ] || { rm -rf "$tmp"; warn "$b not found in $url"; return 1; }
    install -m 755 "$f" "$BIN/$b"
  done
  rm -rf "$tmp"
  ok "$* from $(basename "$url")"
}

# apt package if Debian has it, otherwise the GitHub release
apt_or_release() {
  local cmd=$1 pkg=$2 repo=$3 regex=$4; shift 4
  if have "$cmd"; then ok "$cmd already installed"; return; fi
  if apt-cache show "$pkg" >/dev/null 2>&1 && sudo apt-get install -y "$pkg" >/dev/null; then
    ok "$cmd via apt"
  else
    install_from_release "$repo" "$regex" "$@" || warn "could not install $cmd"
  fi
}

# ---------- neovim (official release, Debian only) ----------
nvim_ok() {
  have nvim || return 1
  local v
  v=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
  [ "$(printf '%s\n%s\n' "$NVIM_MIN" "$v" | sort -V | head -n1)" = "$NVIM_MIN" ]
}

install_neovim_release() {
  if nvim_ok; then ok "neovim $(nvim --version | head -n1 | cut -d' ' -f2) already installed"; return; fi
  local name="nvim-linux-$( [ "$ARCH" = aarch64 ] && echo arm64 || echo x86_64 )"
  local tmp; tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/nvim.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/$name.tar.gz"
  sudo rm -rf "/opt/$name"
  sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
  sudo ln -sf "/opt/$name/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp"
  ok "neovim $(/usr/local/bin/nvim --version | head -n1 | cut -d' ' -f2) in /opt/$name"
}

# ---------- steps ----------
step_packages() {
  info "System packages ($PM)"
  if [ "$PM" = apt ]; then
    sudo apt-get update -qq
    # shellcheck disable=SC2046
    sudo apt-get install -y $(read_list "$DOTFILES/packages/apt.txt")
    ok "apt packages"

    info "Extra tools"
    install_neovim_release
    apt_or_release lazygit lazygit jesseduffield/lazygit "Linux_($ARCH|$ARCH_ALT)\.tar\.gz$"        lazygit
    apt_or_release gping   gping   orf/gping            "(($ARCH|$ARCH_ALT).*linux|linux.*($ARCH|$ARCH_ALT)).*\.tar\.gz$" gping
    apt_or_release yazi    yazi    sxyazi/yazi          "yazi-$ARCH-unknown-linux-gnu\.zip$"          yazi ya
  else
    # shellcheck disable=SC2046
    sudo pacman -S --needed --noconfirm $(read_list "$DOTFILES/packages/pacman.txt")
    ok "pacman packages"
  fi
}

step_link() {
  info "Linking configs into $HOME"
  have stow || die "stow missing — run './install.sh packages' first"
  # --no-folding: create real directories, link only files
  # (so untracked files like ~/.config/shell/local.sh never land inside the repo)
  stow --no-folding --restow -d "$DOTFILES" -t "$HOME" shell
  ok "shell configs linked"

  info "Hooking ~/.config/shell/init.sh into your shell"
  local line='[ -f "$HOME/.config/shell/init.sh" ] && . "$HOME/.config/shell/init.sh"  # dotfiles'
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    if grep -qF '.config/shell/init.sh' "$rc"; then
      ok "$(basename "$rc") already hooked"
    else
      printf '\n%s\n' "$line" >> "$rc"
      ok "added to $(basename "$rc")"
    fi
  done
}

step_nvim() {
  info "Neovim config"
  if [ -d "$HOME/.config/nvim/.git" ]; then
    ok "~/.config/nvim already a git repo ($(git -C "$HOME/.config/nvim" remote get-url origin 2>/dev/null || echo 'no remote'))"
  elif [ -e "$HOME/.config/nvim" ]; then
    warn "~/.config/nvim exists but is not a git repo — left untouched"
  else
    git clone -q "$NVIM_REPO" "$HOME/.config/nvim"
    have nvim && nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || true
    ok "cloned $NVIM_REPO and installed plugins"
  fi
}

case "${1:-all}" in
  packages) step_packages ;;
  link)     step_link ;;
  nvim)     step_nvim ;;
  all)      step_packages; step_link; step_nvim ;;
  *) die "usage: $0 [all|packages|link|nvim]" ;;
esac

info "Done. Open a new shell (or run: exec \$SHELL) to load the aliases."
