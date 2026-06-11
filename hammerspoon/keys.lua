local newTerminal = function()
  -- Run cmux via AppleScript's `do shell script` instead of directly from
  -- Hammerspoon. Direct hs.task/hs.execute calls can hit cmux socket broken-pipe
  -- errors from Hammerspoon's GUI process environment.
  local ok, result = hs.osascript.applescript([[
    do shell script "env -i HOME=/Users/tej PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin /opt/homebrew/bin/cmux new-window 2>&1"
  ]])

  if not ok then
    hs.execute([[/usr/bin/open -a cmux]])
    hs.printf("cmux new-window failed: %s", result or "")
  end

  hs.timer.doAfter(0.2, function()
    local app = hs.application.find("cmux")
    if app then
      app:activate()
    end
  end)
end

-- hyper+t
-- right fn+pg up on gmmk2
hs.hotkey.bind("ctrl-alt-cmd-shift", "t", newTerminal)

hs.hotkey.bind("ctrl-alt-shift", "1", function()
	hs.caffeinate.lockScreen()
end)
-- meh-3 and hyper-3
-- home and fn2+home on q2 pro
hs.hotkey.bind("ctrl-alt-shift", "3", newTerminal)
hs.hotkey.bind("ctrl-cmd-alt-shift", "3", newTerminal)

local insertDate = function()
  local d = os.date("%Y-%m-%d")
  hs.eventtap.keyStrokes(d)
end
hs.hotkey.bind("cmd-shift", "d", insertDate)
