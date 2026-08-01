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
  direnv
  dust
  elan-init
  emscripten
  eza
  fd
  fish
  fx
  fzf
  gh
  git-delta
  gnu-sed
  gnu-tar
  go
  grep
  jq
  make
  neovim
  opam
  pandoc
  pkgconf
  poppler
  python@3.13
  ripgrep
  rustup
  shellcheck
  starship
  texinfo
  tmux
  tokei
  tree
  tree-sitter-cli
  wget
  zapp
)

casks=(
  1password
  1password-cli
  alfred
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
  keybase
  keymapp
  linear
  logitech-g-hub
  notion
  orbstack
  slack
  spotify
  tldraw
  timing
  visual-studio-code
  wispr-flow
  zed
  zoom
)

install_taps "${taps[@]}"
brew install "${formulae[@]}"
brew install --cask "${casks[@]}"
