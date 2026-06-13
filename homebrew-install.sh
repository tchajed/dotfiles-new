#!/usr/bin/env bash
set -euo pipefail

# Install Homebrew packages for this machine.
#
# Formulae were generated from:
#   fish -lc 'brew leaves'
# Casks were generated from:
#   fish -lc 'brew list --cask'
#
# Keep these arrays sorted so diffs stay easy to review.

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed. Install it from https://brew.sh/ first." >&2
  exit 1
fi

install_taps() {
  local tap
  for tap in "$@"; do
    brew tap "$tap"
  done
}

taps=(
  d12frosted/emacs-plus
)

formulae=(
  autoconf
  autojump
  awk
  bat
  btop
  bun
  cmake
  d12frosted/emacs-plus/emacs-plus@30
  devcontainer
  elan-init
  emscripten
  eza
  fd
  fish
  fx
  fzf
  gh
  gnu-sed
  gnu-tar
  go
  grep
  make
  neovim
  opam
  pandoc
  pkgconf
  poppler
  python@3.13
  rustup
  starship
  texinfo
  tmux
  tokei
  tree
  wget
)

casks=(
  1password
  1password-cli
  claude
  claude-code
  cmux
  codex
  dropbox
  font-inconsolata-nerd-font
  font-noto-sans-symbols-2
  font-open-sans
  font-roboto
  font-roboto-mono-nerd-font
  font-symbols-only-nerd-font
  font-victor-mono-nerd-font
  gcloud-cli
  google-chrome
  hammerspoon
  karabiner-elements
  linear
  logitech-g-hub
  notion
  orbstack
  slack
  timing
  visual-studio-code
  wispr-flow
  zoom
)

install_taps "${taps[@]}"
brew install "${formulae[@]}"
brew install --cask "${casks[@]}"
