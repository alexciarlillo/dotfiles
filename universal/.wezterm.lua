-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

local act = wezterm.action
local mux = wezterm.mux

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Mocha"

config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 16

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 5,
}

config.window_decorations = "RESIZE"
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1500 }

local function move_pane(key, direction)
	return {
		key = key,
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

config.keys = {
	{
		key = "k",
		mods = "CMD",
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
	},
	{
		key = "b",
		mods = "LEADER",
		action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
	},
	{
		-- When we push LEADER + R...
		key = "r",
		mods = "LEADER",
		-- Activate the `resize_panes` keytable
		action = wezterm.action.ActivateKeyTable({
			name = "resize_panes",
			-- Ensures the keytable stays active after it handles its
			-- first keypress.
			one_shot = false,
			-- Deactivate the keytable after a timeout.
			timeout_milliseconds = 1000,
		}),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	move_pane("j", "Down"),
	move_pane("k", "Up"),
	move_pane("h", "Left"),
	move_pane("l", "Right"),
}

config.key_tables = {
	resize_panes = {
		resize_pane("j", "Down"),
		resize_pane("k", "Up"),
		resize_pane("h", "Left"),
		resize_pane("l", "Right"),
	},
}

-- wezterm.on("gui-startup", function()
-- 	-- Check for the specific argument, e.g., `--my-custom-start`
-- 	if os.getenv("WEZTERM_GUILDED") == "1" then
-- 		local tab, pane, window = wezterm.mux.spawn_window({})
--
-- 		-- First Tab: Create a vertical split
-- 		pane:split({ direction = "Right" })
-- 		pane:split({ direction = "Right" })
--
-- 		-- Second Tab: Create a new tab with a vertical split
-- 		tab = window:spawn_tab({})
-- 		tab:active_pane():split({ direction = "Right" })
-- 	end
-- end)

-- wezterm.on("gui-startup", function(cmd)
-- 	-- allow `wezterm start -- something` to affect what we spawn
-- 	-- in our initial window
-- 	local args = {}
-- 	if cmd then
-- 		args = cmd.args
-- 	end
--
-- 	-- Set a workspace for coding on a current project
-- 	-- Top pane is for the editor, bottom pane is for the build tool
-- 	local tab, build_pane, window = mux.spawn_window({
-- 		workspace = "coding",
-- 	})
-- 	local editor_pane = build_pane:split({
-- 		direction = "Top",
-- 		size = 0.6,
-- 	})
--
-- 	-- A workspace for interacting with a local machine that
-- 	-- runs some docker containners for home automation
-- 	local tab, pane, window = mux.spawn_window({
-- 		workspace = "automation",
-- 	})
--
-- 	-- We want to startup in the coding workspace
-- 	mux.set_active_workspace("coding")
-- end)

-- and finally, return the configuration to wezterm
return config
