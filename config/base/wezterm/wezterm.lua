local wezterm = require("wezterm")
local config = wezterm.config_builder()
local is_mac = wezterm.target_triple:find("darwin") ~= nil

-- ==================== Font ====================
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0

-- ==================== Catppuccin Mocha ====================
local c = {
	rosewater = "#f5e0dc",
	flamingo = "#f2cdcd",
	pink = "#f5c2e7",
	mauve = "#cba6f7",
	red = "#f38ba8",
	maroon = "#eba0ac",
	peach = "#fab387",
	yellow = "#f9e2af",
	green = "#a6e3a1",
	teal = "#94e2d5",
	sky = "#89dceb",
	sapphire = "#74c7ec",
	blue = "#89b4fa",
	lavender = "#b4befe",
	text = "#cdd6f4",
	subtext1 = "#bac2de",
	subtext0 = "#a6adc8",
	overlay2 = "#9399b2",
	overlay1 = "#7f849c",
	overlay0 = "#6c7086",
	surface2 = "#585b70",
	surface1 = "#45475a",
	surface0 = "#313244",
	base = "#1e1e2e",
	mantle = "#181825",
	crust = "#11111b",
}

config.colors = {
	foreground = c.text,
	background = c.base,
	cursor_fg = c.base,
	cursor_bg = c.rosewater,
	cursor_border = c.rosewater,
	selection_fg = c.text,
	selection_bg = c.surface0,
	ansi = {
		c.surface1,
		c.red,
		c.green,
		c.yellow,
		c.blue,
		c.mauve,
		c.teal,
		c.subtext1,
	},
	brights = {
		c.overlay0,
		c.red,
		c.green,
		c.yellow,
		c.blue,
		c.mauve,
		c.teal,
		c.subtext0,
	},
	tab_bar = {
		background = c.crust,
		active_tab = { bg_color = c.base, fg_color = c.text },
		inactive_tab = { bg_color = c.mantle, fg_color = c.overlay1 },
		inactive_tab_hover = { bg_color = c.surface0, fg_color = c.text },
		new_tab = { bg_color = c.mantle, fg_color = c.overlay1 },
		new_tab_hover = { bg_color = c.surface0, fg_color = c.text },
	},
}

-- ==================== Cursor ====================
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0

-- ==================== Window ====================
config.initial_cols = 120
config.initial_rows = 36
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_background_opacity = 0.95

if is_mac then
	config.macos_window_background_blur = 20
	config.option_as_alt = "Both"
end

-- ==================== Scrollback ====================
config.scrollback_lines = 50000

-- ==================== Tab Bar ====================
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false

-- ==================== Shell ====================
if is_mac then
	config.default_prog = { "/bin/zsh" }
else
	config.default_prog = { "/usr/bin/zsh" }
end

-- ==================== Misc ====================
config.adjust_window_size_when_changing_font_size = false
config.audible_bell = "Disabled"

wezterm.on("gui-startup", function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return config
