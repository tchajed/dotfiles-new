function agents-awake --description 'Prevent idle system sleep while agents are running'
    command caffeinate -i $argv
end
