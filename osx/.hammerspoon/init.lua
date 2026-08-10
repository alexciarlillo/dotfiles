hyper = { "⌘", "⌥", "⌃" }
hs.window.animationDuration = 0

local home = os.getenv("HOME")

-- Window focus hints
-- hs.hotkey.bind(hyper, "return", hs.hints.windowHints)

-- Launch new wezterm window on current desktop
hs.hotkey.bind({ "alt" }, "return", function()
	-- hs.osascript.applescriptFromFile(home .. "/.local/bin/new-wezterm.applescript")
	hs.osascript.applescriptFromFile(home .. "/.local/bin/new-ghostty.applescript")
end)

-- launch script on unlock and log to file
hs.caffeinate.watcher
	.new(function(event)
		if event == hs.caffeinate.watcher.screensDidUnlock then
			-- log script with errors
			hs.execute(home .. "/.local/bin/unlock > /tmp/unlock.log 2>&1", true)
		end
	end)
	:start()
