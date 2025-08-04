local wezterm = require 'wezterm';

-- タブタイトルを現在のディレクトリ名に設定する関数
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title
  -- プロセス名とパスから現在のディレクトリを取得
  if tab.active_pane.current_working_dir then
    local cwd = tab.active_pane.current_working_dir.file_path
    local basename = string.match(cwd, "([^/]+)$")
    if basename then
      title = basename
    end
  end
  return title
end)

return {
  -- font
  font = wezterm.font('JetBrains Mono', { weight = 'Medium', italic = true }),
  font_size = 15.0,

  window_background_opacity = 0.85,

  -- color scheme
  color_scheme = "Kanagawa (Gogh)",

  tab_bar_at_bottom = true,

  -- タブタイトルの設定
  tab_max_width = 32,

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

