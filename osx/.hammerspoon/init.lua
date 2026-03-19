hyper = { "⌘", "⌥", "⌃" }
hs.window.animationDuration = 0

-- Window focus hints
hs.hotkey.bind(hyper, "return", hs.hints.windowHints)

-- Launch new wezterm window on current desktop
hs.hotkey.bind({ "alt" }, "return", function()
	hs.osascript.applescriptFromFile("/Users/alex/.local/bin/new-wezterm.applescript")
end)

-- launch script on unlock and log to file
hs.caffeinate.watcher
	.new(function(event)
		if event == hs.caffeinate.watcher.screensDidUnlock then
			-- log script with errors
			hs.execute("/Users/alex/.local/bin/unlock > /tmp/unlock.log 2>&1", true)
		end
	end)
	:start()
