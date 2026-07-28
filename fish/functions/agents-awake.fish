function agents-awake --description 'Prevent idle system sleep while agents are running'
    echo 'Keeping this Mac awake for agents; press Ctrl-C to stop.'
    command caffeinate -i $argv
end
