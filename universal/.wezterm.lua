-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

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

-- and finally, return the configuration to wezterm
return config
