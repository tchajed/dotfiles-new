# dotfiles-theorem

Tej's dotfiles for work at [Theorem](https://theorem.dev) managed by [dotbot](https://github.com/anishathalye/dotbot).

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
