# dotfiles-theorem

Tej's dotfiles for work at [Theorem](https://theorem.dev) managed by [dotbot](https://github.com/anishathalye/dotbot).

## Setup

Bootstrapping: on a new laptop, use Safari and Terminal.app to install [Homebrew](https://brew.sh), then run this installer to replace the browser and terminal.

```sh
git submodule update --init --recursive
./install
```

`./install` also applies macOS defaults from `macos/defaults.sh`.

Install Homebrew packages with:

```sh
./homebrew-install.sh
```

Keep the Homebrew arrays sorted; they are generated from `fish -lc 'brew leaves'` and `fish -lc 'brew list --cask'`.

## Manual dependency

Install [Bear from the Mac App Store](https://apps.apple.com/app/bear-markdown-notes/id1091189122). The installer configures Bear's view shortcuts and prints this link when the app is missing.
