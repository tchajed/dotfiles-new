#!/usr/bin/env bash

set -euo pipefail

# Disable press-and-hold for accents in favor of normal key repeat.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable “natural” scrolling.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo "Configured macOS keyboard and scrolling defaults. Restart apps or log out/in for all changes to apply."
