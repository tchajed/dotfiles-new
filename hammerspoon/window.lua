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
hs.grid.setGrid("4x3", "Color LCD")

hs.grid.setMargins({ w = 0, h = 0 })
hs.hotkey.bind({ "shift", "cmd" }, "g", function()
	hs.grid.show()
end)

-- when screens change, grid gets messed up; reconfiguring it recalculates it
local function reconfigureGrid()
	hs.grid.setGrid(hs.grid.getGrid())
end

local screenWatcher = hs.screen.watcher.new(reconfigureGrid)
screenWatcher:start()
