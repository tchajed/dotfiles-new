# dotfiles-new

Tej's personal dotfiles for managed by [dotbot](https://github.com/anishathalye/dotbot). This iteration is almost entirely managed by AI - this has made it both easy to use and more reliable.

## Fresh-machine setup

Before bootstrapping a new Mac:

1. Log in with an administrator account.
2. Install the Xcode Command Line Tools with `xcode-select --install` if they are not already available.
3. Install [Homebrew](https://brew.sh/).
4. Clone this repository.

Then run the single installer:

```sh
git clone https://github.com/tchajed/dotfiles-new.git
cd dotfiles-theorem
./install
```

`./install` checks the root [`Brewfile`](Brewfile), installs any missing Homebrew formulae and applications, and only then links the configurations with Dotbot, applies `macos/defaults.sh`, and makes Fish the default login shell. It is safe to run again: Homebrew skips dependencies that are already installed and Dotbot relinks the managed files.

To check the Homebrew dependencies without installing anything, run:

```sh
brew bundle check --no-upgrade --file Brewfile
```

Keep the formulae and casks in `Brewfile` sorted so changes remain easy to review.

## Manual setup after installation

macOS does not allow the installer to approve privacy and security prompts on your behalf. After `./install` completes:

### Hammerspoon

1. Open Hammerspoon once.
2. In **System Settings → Privacy & Security → Accessibility**, allow Hammerspoon.
3. Reload its configuration from the Hammerspoon menu, or run `hs -c "hs.reload()"`.

### Karabiner-Elements

1. Open Karabiner-Elements once and follow its setup prompts.
2. Approve its driver/system extension under **System Settings → Privacy & Security** when prompted.
3. Grant its components **Input Monitoring** access when prompted.
4. Confirm that the linked `~/.config/karabiner/karabiner.json` configuration is active.

### 1Password

1. Open 1Password, sign in, and authorize the Mac.
2. In **1Password → Settings → Developer**, enable integration with the 1Password CLI.
3. Enable biometric unlock if you want `op` CLI commands to authorize through the desktop app.
4. Enable the 1Password browser extension separately in each browser you use.

### Raycast

1. Open Raycast, complete onboarding, and use the default `⌥ Space` hotkey (or change it in **Raycast Settings → General**).
2. Disable Spotlight's conflicting shortcut in **System Settings → Keyboard → Keyboard Shortcuts → Spotlight** if needed.
3. Install [Bear Notes](https://www.raycast.com/hmarr/bear) from the Raycast Store and use Raycast's built-in **Notes** for quick notes.
4. Use Raycast's built-in **Calculator** for unit conversions (for example, `10 km in miles`); no separate extension is required.
5. In **Raycast Settings → Extensions**, assign aliases or hotkeys to **Search Notes**, **Create Note**, **Notes**, and **Calculator** as desired.
6. Once Raycast is working, remove Alfred from Login Items if macOS retained it.

### Bear

Install [Bear from the Mac App Store](https://apps.apple.com/app/bear-markdown-notes/id1091189122). The Bear Notes extension may ask for permission to access Bear's notes database the first time it runs.
