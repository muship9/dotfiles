local wezterm = require 'wezterm';

return {
  -- font
  font = wezterm.font('JetBrains Mono', { weight = 'Medium', italic = true }),
  font_size = 15.0,

  window_background_opacity = 0.85,

  -- color scheme
  color_scheme = "Kanagawa (Gogh)",

  tab_bar_at_bottom = true,

  automatically_reload_config = true,

  -- key bindings
  keys = {
    {
      key = 'l',
      mods = 'CMD',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'h',
      mods = 'CMD',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'j',
      mods = 'CMD',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'k',
      mods = 'CMD',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'w',
      mods = 'CMD|SHIFT',
      action = wezterm.action.CloseCurrentPane { confirm = true },
    },
  },
}

