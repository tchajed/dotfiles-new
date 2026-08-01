# Initialize zoxide's directory-jumping command and Fish completions.
if command -q zoxide
    zoxide init fish | source
end
