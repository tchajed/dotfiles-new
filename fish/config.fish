if status is-interactive
    # Starship prompt
    starship init fish | source

    alias vim nvim
    alias ls eza

    # Set up fzf key bindings
    if command -q fzf
        fzf --fish | source
        # fd respects ignore files. Use the directory parsed by fzf's Fish
        # widget so `fish/con<ctrl-t>` searches only inside `fish/`.
        # This doesn't affect fzf used directly (e.g., `vim (fzf)`).
        set -gx FZF_CTRL_T_COMMAND 'if test "$dir" = .; fd --type f --strip-cwd-prefix; else; fd --type f . "$dir"; end'
        set -gx FZF_DEFAULT_OPTS '--select-1 --exit-0'

        # Alt-T is the inclusive variant: show hidden and ignored files, while
        # still avoiding Git's internal object database.
        function fzf-file-widget-all --description 'List files, including hidden and ignored files'
            set -lx FZF_CTRL_T_COMMAND 'if test "$dir" = .; fd --type f --hidden --no-ignore --exclude .git --strip-cwd-prefix; else; fd --type f --hidden --no-ignore --exclude .git . "$dir"; end'
            fzf-file-widget
        end
        bind \et fzf-file-widget-all
        bind -M insert \et fzf-file-widget-all
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
fish_add_path --prepend ~/code/pi-tools

# Homebrew rustup is keg-only, so cargo/rustc shims live here.
if command -q brew
    fish_add_path --prepend (brew --prefix rustup)/bin
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r "$HOME/.opam/opam-init/init.fish" && source "$HOME/.opam/opam-init/init.fish" >/dev/null 2>/dev/null; or true
# END opam configuration
