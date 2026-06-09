if status is-interactive
    # Starship prompt
    starship init fish | source

    alias vim nvim
    alias ls eza

    # Set up fzf key bindings
    if command -q fzf
        fzf --fish | source
        # fd will respect gitignore
        # this doesn't affect fzf used directly (e.g., `vim (fzf)`)
        set -gx FZF_CTRL_T_COMMAND 'fd --type f --strip-cwd-prefix'
        set -gx FZF_DEFAULT_OPTS '--select-1 --exit-0'
    end

    function fish_greeting
    end
end

# Doom Emacs
fish_add_path $HOME/.emacs.d/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path --prepend $BUN_INSTALL/bin

fish_add_path --prepend ~/.local/bin
fish_add_path --prepend ~/go/bin

# Homebrew rustup is keg-only, so cargo/rustc shims live here.
fish_add_path --prepend /opt/homebrew/opt/rustup/bin

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/Users/tej/.opam/opam-init/init.fish' && source '/Users/tej/.opam/opam-init/init.fish' >/dev/null 2>/dev/null; or true
# END opam configuration
