#!/usr/bin/env bash

set -euo pipefail

# Disable press-and-hold for accents in favor of normal key repeat.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable “natural” scrolling.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Bear: swap ⌃1 and ⌃3 (Show Editor Only <-> Show Tags, Notes and Editor),
# keep ⌃2 at its default (Show Notes and Editor).
defaults write net.shinyfrog.bear NSUserKeyEquivalents -dict-add "Show Editor Only" "^3"
defaults write net.shinyfrog.bear NSUserKeyEquivalents -dict-add "Show Notes and Editor" "^2"
defaults write net.shinyfrog.bear NSUserKeyEquivalents -dict-add "Show Tags, Notes and Editor" "^1"

echo "Configured macOS keyboard and scrolling defaults. Restart apps or log out/in for all changes to apply."
