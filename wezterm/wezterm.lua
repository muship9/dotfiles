local wezterm = require 'wezterm';

return {
  -- font
  font = wezterm.font('JetBrains Mono', { weight = 'Medium', italic = true }),
  font_size = 15.0,

  window_background_opacity = 0.85,

  -- color scheme
  color_scheme = "Kanagawa (Gogh)",

  tab_bar_at_bottom = true,
}

