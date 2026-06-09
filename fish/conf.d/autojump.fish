# Load autojump
if test -f /opt/homebrew/share/autojump/autojump.fish
    source /opt/homebrew/share/autojump/autojump.fish
end

# Use `z` as the jump command (wraps autojump's `j`)
function z --wraps j --description 'autojump'
    j $argv
end

# tab completion for z
complete -x -c z -a '(autojump --complete (commandline -t))'
