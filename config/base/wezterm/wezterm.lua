local wezterm = require("wezterm")
local config = wezterm.config_builder()
local is_mac = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- ==================== Font ====================
config.font = wezterm.font("JetBrainsMono Nerd Font")
if is_mac then
	config.font_size = 14.0
else
	config.font_size = 12.0
end

-- ==================== Window ====================
config.window_background_opacity = 0.95

if is_mac then
	config.macos_window_background_blur = 20
	config.send_composed_key_when_left_alt_is_pressed = false
	config.send_composed_key_when_right_alt_is_pressed = false
elseif is_linux then
	config.enable_wayland = false
end

-- ==================== Scrollback ====================
config.scrollback_lines = 50000

-- ==================== Tab Bar ====================
config.hide_tab_bar_if_only_one_tab = true

-- ==================== Shell ====================
if is_mac then
	config.default_prog = { "/bin/zsh" }
elseif is_linux then
	config.default_prog = { "/usr/bin/zsh" }
elseif is_windows then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- ==================== Misc ====================
config.adjust_window_size_when_changing_font_size = false
config.audible_bell = "Disabled"

wezterm.on("gui-startup", function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return config
