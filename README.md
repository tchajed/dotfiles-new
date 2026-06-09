# dotfiles-theorem

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot).

This repo tracks only configuration that was live-installed on this machine when it was created, plus a Homebrew install script generated from currently installed packages.

## Setup

```sh
git submodule update --init --recursive
./install
```

Install Homebrew packages with:

```sh
./homebrew-install.sh
```

Keep the Homebrew arrays sorted; they are generated from `fish -lc 'brew leaves'` and `fish -lc 'brew list --cask'`.
