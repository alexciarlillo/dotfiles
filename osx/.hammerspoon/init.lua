hyper = { "⌘", "⌥", "⌃" }
shyper = { "⌘", "⌥", "⌃", "shift" }
meh = { "⌥", "⌃", "shift" }
missionControlKey = { "alt" }
hs.window.animationDuration = 0

-- hs.loadSpoon("hs_select_window")
-- local spaces = require("hs.spaces")

-- Select windows
-- local SWbindings = {
-- 	all_windows = { { "⌘", "⌥" }, "e" },
-- }
-- spoon.hs_select_window:bindHotkeys(SWbindings)

-- Window focus hints
hs.hotkey.bind({ "alt", "ctrl" }, "e", hs.hints.windowHints)

-- Launch new iTerm window on current desktop
hs.hotkey.bind({ "alt" }, "return", function()
	hs.osascript.applescriptFromFile("/Users/alex/.bin/wezterm-new.scpt")
end)
-- Grid config

hs.grid.setGrid("12x12")
hs.grid.setMargins("4x4")

local gridset = function(x, y, w, h)
	return function()
		local win = hs.window.focusedWindow()
		hs.grid.set(win, { x = x, y = y, w = w, h = h }, win:screen())
	end
end

-- fullscreen
hs.hotkey.bind(hyper, "k", gridset(2, 0, 8, 12))

-- -- top left
-- hs.hotkey.bind(hyper, "u", gridset(0, 0, 6, 6))
-- -- top right
-- hs.hotkey.bind(hyper, "o", gridset(6, 0, 6, 6))
-- -- bottom right
-- hs.hotkey.bind(hyper, ".", gridset(6, 6, 6, 6))
-- -- bottom left
-- hs.hotkey.bind(hyper, "m", gridset(0, 6, 6, 6))
--
-- -- left half
-- hs.hotkey.bind(hyper, "j", gridset(0, 0, 6, 12))
-- -- right half
-- hs.hotkey.bind(hyper, "l", gridset(6, 0, 6, 12))
-- -- top half
-- hs.hotkey.bind(hyper, "i", gridset(0, 0, 12, 6))
-- -- bottom half
-- hs.hotkey.bind(hyper, ",", gridset(0, 6, 12, 6))
-- -- center half
-- hs.hotkey.bind(hyper, "8", gridset(2, 0, 8, 12))
--
-- -- horizonal 1/3's
-- hs.hotkey.bind(hyper, "7", gridset(0, 0, 4, 12))
-- hs.hotkey.bind(hyper, "9", gridset(8, 0, 4, 12))
--
-- -- horizontal 2/3's
-- hs.hotkey.bind(hyper, "6", gridset(0, 0, 8, 12))
-- hs.hotkey.bind(hyper, "0", gridset(4, 0, 8, 12))
--
-- -- vertical 1/3's
-- hs.hotkey.bind(hyper, "y", gridset(0, 0, 12, 4))
-- hs.hotkey.bind(hyper, "h", gridset(0, 4, 12, 4))
-- hs.hotkey.bind(hyper, "n", gridset(0, 8, 12, 4))
--
-- -- vertical 2/3's
-- hs.hotkey.bind(hyper, "p", gridset(0, 0, 12, 8))
-- hs.hotkey.bind(hyper, "/", gridset(0, 4, 12, 8))
--
-- -- move window to next screen
--
-- hs.hotkey.bind(meh, "tab", function()
-- 	-- get the focused window
-- 	local win = hs.window.focusedWindow()
-- 	-- get the screen where the focused window is displayed, a.k.a. current screen
-- 	local screen = win:screen()
--
-- 	-- compute the unitRect of the focused window relative to the current screen
-- 	-- and move the window to the next screen setting the same unitRect
-- 	win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
--
-- 	-- center it
-- 	hs.grid.set(win, { x = 1, y = 1, w = 10, h = 10 }, win:screen())
-- end)

-- throw to spaces
--
-- function GetTableLng(tbl)
-- 	local getN = 0
-- 	for n in pairs(tbl) do
-- 		getN = getN + 1
-- 	end
-- 	return getN
-- end
--
-- function sortedSpaceIndexesToIds(allSpaces)
-- 	local result = {}
-- 	for k, v in
-- 		hs.fnutils.sortByKeyValues(allSpaces, function(v1, v2)
-- 			return GetTableLng(v1) > GetTableLng(v2)
-- 		end)
-- 	do
-- 		local spaceAndScreenMap = {}
-- 		for i, spaceId in ipairs(v) do
-- 			table.insert(spaceAndScreenMap, { spaceId = spaceId, screenId = k })
-- 		end
-- 		result = hs.fnutils.concat(result, spaceAndScreenMap)
-- 	end
-- 	return result
-- end
--
-- spacesMap = {
-- 	{ "w", 1 },
-- 	{ "e", 2 },
-- 	{ "r", 3 },
-- 	{ "s", 4 },
-- 	{ "d", 5 },
-- 	{ "f", 6 },
-- 	{ "x", 7 },
-- 	{ "c", 8 },
-- 	{ "v", 9 },
-- 	{ "t", 10 },
-- 	{ "g", 11 },
-- 	{ "b", 12 },
-- 	{ "q", 13 },
-- 	{ "a", 14 },
-- 	{ "z", 15 },
-- }
--
-- for key, mapping in ipairs(spacesMap) do
-- 	hs.hotkey.bind(meh, mapping[1], function()
-- 		local win = hs.window.focusedWindow()
--
-- 		if not win then
-- 			return
-- 		end
--
-- 		local spaceIdx = mapping[2]
-- 		local spacesByIndex = sortedSpaceIndexesToIds(spaces.allSpaces())
-- 		local spaceId = spacesByIndex[spaceIdx].spaceId
-- 		local newScreen = spacesByIndex[spaceIdx].screenId
-- 		local oldScreen = win:screen():getUUID()
-- 		local primaryScreen = hs.screen.primaryScreen():getUUID()
--
-- 		if newScreen == oldScreen then
-- 			-- do nothing
-- 		elseif newScreen == primaryScreen then
-- 			hs.grid.set(win, { x = 3, y = 0, w = 6, h = 12 }, newScreen)
-- 		else
-- 			hs.grid.set(win, { x = 0, y = 0, w = 12, h = 12 }, newScreen)
-- 		end
--
-- 		spaces.moveWindowToSpace(win:id(), spaceId)
-- 		hs.eventtap.keyStroke(missionControlKey, mapping[1])
--
-- 		hs.timer.doAfter(0.1, function()
-- 			win:focus()
-- 		end)
-- 	end)
-- end
