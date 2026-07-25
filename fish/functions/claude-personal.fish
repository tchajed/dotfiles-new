function claude-personal --description 'Launch claude with the personal config dir isolation'
    # Distinguish this profile visually: light lavender background + dark purple text + tab title
    # (OSC 11 / OSC 10 / OSC 2). Resets automatically via OSC 111 / 110 when the command exits.
    # OSC 11/10 change default background/foreground; use BEL terminator for Ghostty/cmux compatibility.
    printf '\e]11;rgb:ee/e6/ff\a'
    printf '\e]10;rgb:24/16/3a\a'
    printf '\e]2;claude-personal\a'

    env CLAUDE_CONFIG_DIR=$HOME/.claude-personal command claude $argv

    printf '\e]110\a'
    printf '\e]111\a'
end
