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

-- Mouse side buttons: switch Spaces.
-- CGEvent/Hammerspoon numbers mouse buttons from 0:
--   physical mouse button 4 -> button number 3
--   physical mouse button 5 -> button number 4
local mouseButtonToSpaceDirection = {
	[3] = -1,
	[4] = 1,
}

local function switchSpace(offset)
	local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
	local screenSpaces = hs.spaces.allSpaces()[screen:getUUID()]
	local currentSpace = hs.spaces.activeSpaceOnScreen(screen)
	if not screenSpaces or not currentSpace then
		return
	end

	for i, space in ipairs(screenSpaces) do
		if space == currentSpace then
			local targetSpace = screenSpaces[i + offset]
			if targetSpace then
				hs.spaces.gotoSpace(targetSpace)
			end
			return
		end
	end
end

-- Keep this global so Lua GC doesn't collect and stop the eventtap.
spaceMouseTap = hs.eventtap.new({
	hs.eventtap.event.types.otherMouseDown,
	hs.eventtap.event.types.otherMouseUp,
}, function(event)
	local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
	local offset = mouseButtonToSpaceDirection[button]
	if not offset then
		return false
	end

	if event:getType() == hs.eventtap.event.types.otherMouseDown then
		switchSpace(offset)
	end

	return true
end)
spaceMouseTap:start()
