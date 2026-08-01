# Load autojump from the active Homebrew installation.
if command -q brew
    set --local autojump_init (brew --prefix autojump)/share/autojump/autojump.fish
    if test -f "$autojump_init"
        source "$autojump_init"
    end
end

# Use `z` as the jump command (wraps autojump's `j`)
function z --wraps j --description 'autojump'
    j $argv
end

# tab completion for z
complete -x -c z -a '(autojump --complete (commandline -t))'
