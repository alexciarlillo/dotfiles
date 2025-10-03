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

-- Enable extended key support for tmux/nvim C-i vs Tab distinction
config.enable_kitty_keyboard = true

-- COMMENTED OUT: Let tmux handle all leader-based commands
-- config.leader = { key = "Space", mods = "CMD|SHIFT", timeout_milliseconds = 1500 }

local function move_pane(key, direction)
	return {
		key = key,
		mods = "ALT|SHIFT",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

-- TMUX MIGRATION: Most keybindings commented out to avoid conflicts with tmux
-- Backup available at .wezterm.lua.backup
-- Only keeping essential WezTerm-specific bindings that don't conflict

config.keys = {
	-- COMMENTED OUT: CMD+k clears entire terminal and wipes tmux layouts
	-- Use tmux's Leader+k instead for safer clearing
	-- {
	-- 	key = "k",
	-- 	mods = "CMD",
	-- 	action = act.Multiple({
	-- 		act.ClearScrollback("ScrollbackAndViewport"),
	-- 		act.SendKey({ key = "L", mods = "CTRL" }),
	-- 	}),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Leader+s (split vertical)
	-- {
	-- 	key = "s",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Leader+v (split horizontal)
	-- {
	-- 	key = "v",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Leader+t (new window)
	-- {
	-- 	key = "t",
	-- 	mods = "LEADER",
	-- 	action = act.SpawnTab("CurrentPaneDomain"),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Leader+w (close window)
	-- {
	-- 	key = "w",
	-- 	mods = "LEADER",
	-- 	action = act.CloseCurrentTab({ confirm = true }),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Alt+Ctrl+j (previous window)
	-- {
	-- 	key = "j",
	-- 	mods = "CTRL|ALT",
	-- 	action = act.ActivateTabRelative(-1),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Alt+Ctrl+k (next window)
	-- {
	-- 	key = "k",
	-- 	mods = "CTRL|ALT",
	-- 	action = act.ActivateTabRelative(1),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Alt+Ctrl+, (last window)
	-- {
	-- 	key = ",",
	-- 	mods = "CTRL|ALT",
	-- 	action = act.ActivateLastTab,
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Alt+Ctrl+h (move window left)
	-- {
	-- 	key = "h",
	-- 	mods = "CTRL|ALT",
	-- 	action = act.MoveTabRelative(-1),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Alt+Ctrl+l (move window right)
	-- {
	-- 	key = "l",
	-- 	mods = "CTRL|ALT",
	-- 	action = act.MoveTabRelative(1),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Leader+r (resize mode)
	-- {
	-- 	-- When we push LEADER + R...
	-- 	key = "r",
	-- 	mods = "LEADER",
	-- 	-- Activate the `resize_panes` keytable
	-- 	action = wezterm.action.ActivateKeyTable({
	-- 		name = "resize_panes",
	-- 		-- Ensures the keytable stays active after it handles its
	-- 		-- first keypress.
	-- 		one_shot = false,
	-- 		-- Deactivate the keytable after a timeout.
	-- 		timeout_milliseconds = 1000,
	-- 	}),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Leader+d (close pane)
	-- {
	-- 	key = "d",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action.CloseCurrentPane({ confirm = true }),
	-- },
	
	-- COMMENTED OUT: Conflicts with tmux Alt+Shift+hjkl (pane navigation)
	-- move_pane("j", "Down"),
	-- move_pane("k", "Up"),
	-- move_pane("h", "Left"),
	-- move_pane("l", "Right"),
}

-- Empty keybindings table - all functionality handled by tmux

-- COMMENTED OUT: Conflicts with tmux Alt+Ctrl+1-8 (window selection)
-- for i = 1, 8 do
-- 	-- ALT+SHIFT + number to move to that position
-- 	table.insert(config.keys, {
-- 		key = tostring(i),
-- 		mods = "CTRL|ALT",
-- 		action = wezterm.action.ActivateTab(i - 1),
-- 	})
-- end

-- COMMENTED OUT: Resize table conflicts with tmux resize mode
-- config.key_tables = {
-- 	resize_panes = {
-- 		resize_pane("j", "Down"),
-- 		resize_pane("k", "Up"),
-- 		resize_pane("h", "Left"),
-- 		resize_pane("l", "Right"),
-- 	},
-- }

return config
