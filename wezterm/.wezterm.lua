local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux

wezterm.on('gui-attached', function(domain)
  -- maximize all displayed windows on startup
  local workspace = mux.get_active_workspace()
  for _, window in ipairs(mux.all_windows()) do
    if window:get_workspace() == workspace then
      window:gui_window():maximize()
    end
  end
end)

config.default_prog = { "wsl.exe", "--cd", "~" }
config.color_scheme = "Tokyo Night"
config.enable_tab_bar = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 10
config.window_background_opacity = 0.9
config.window_padding = {
  left = 3,
  right = 0,
  bottom = 0,
  top = 0,
}
config.automatically_reload_config = true
-- config.keys = {
--   {
--     key = "c"
--     mods = "CTRL|SHIFT"
--     action = 
--   }
-- }
return config
