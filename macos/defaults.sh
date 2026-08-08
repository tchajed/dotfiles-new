#!/usr/bin/env bash

set -euo pipefail

# Disable press-and-hold for accents in favor of normal key repeat.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable “natural” scrolling.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Use a click in the trackpad's bottom-right corner as the secondary click.
# Apply this to built-in and Bluetooth trackpads, plus the per-host compatibility keys.
for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
  defaults write "$domain" TrackpadCornerSecondaryClick -int 2
  defaults write "$domain" TrackpadRightClick -bool false
done
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool false

# Bear: swap ⌃1 and ⌃3 (Show Editor Only <-> Show Tags, Notes and Editor),
# keep ⌃2 at its default (Show Notes and Editor).
if ! /usr/bin/open -Ra "Bear" >/dev/null 2>&1; then
  echo "Bear is not installed; install it from the App Store:" >&2
  echo "https://apps.apple.com/app/bear-markdown-notes/id1091189122" >&2
fi

defaults write net.shinyfrog.bear NSUserKeyEquivalents -dict-add "Show Editor Only" "^3"
defaults write net.shinyfrog.bear NSUserKeyEquivalents -dict-add "Show Notes and Editor" "^2"
defaults write net.shinyfrog.bear NSUserKeyEquivalents -dict-add "Show Tags, Notes and Editor" "^1"

echo "Configured macOS keyboard, trackpad, and scrolling defaults. Restart apps or log out/in for all changes to apply."
