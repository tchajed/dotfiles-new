-- grid gui
--
-- per-monitor configuration
-- to identify monitors, look at hs.screen.allScreens()[1] (and possibly [2])

-- default grid
hs.grid.setGrid("8x4")

-- ultrawide displays
hs.grid.setGrid("10x4", "LG HDR WQHD+")
hs.grid.setGrid("10x4", "LG ULTRAWIDE")

-- built-in display
hs.grid.setGrid("4x3", "Built%-in Retina Display")

hs.grid.setMargins({ w = 0, h = 0 })
hs.hotkey.bind({ "shift", "cmd" }, "g", function()
	hs.grid.show()
end)

-- when screens change, grid gets messed up; reconfiguring it recalculates it
local function reconfigureGrid()
	hs.grid.setGrid(hs.grid.getGrid())
end

local screenWatcher = hs.screen.watcher.new(function()
	-- give the displays a moment to settle before recalculating the grid
	hs.timer.doAfter(2, reconfigureGrid)
end)
screenWatcher:start()

local function fixLayout()
	-- cmux: right 4/10ths of the screen, full height
	local cmux = hs.application.get("cmux")
	if cmux then
		local win = cmux:mainWindow()
		if win then
			win:moveToUnit({ x = 0.6, y = 0, w = 0.4, h = 1 })
		end
	end

	-- Intend, if open: left 2/10ths horizontally, bottom 3/4 vertically
	local intend = hs.application.get("Intend")
	if intend then
		local win = intend:mainWindow()
		if win then
			win:moveToUnit({ x = 0, y = 0.25, w = 0.2, h = 0.75 })
		end
	end
end

-- hyper-g (bound to fn2+g on moonlander)
-- layout fix: put my main windows back where they belong
local hyper = { "cmd", "alt", "ctrl", "shift" }
hs.hotkey.bind(hyper, "g", fixLayout)
