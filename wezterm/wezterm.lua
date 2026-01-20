local wezterm = require("wezterm")

-- タブタイトルを現在のディレクトリ名に設定する関数
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
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
  font = wezterm.font_with_fallback({
    { family = "JetBrains Mono",        weight = "Medium", italic = true },
    { family = "Noto Sans Mono CJK JP", weight = "Regular" },
  }),
  font_size = 14.0,

  window_background_opacity = 0.85,
  macos_window_background_blur = 20,

  -- color scheme
  color_scheme = "Kanagawa (Gogh)",

  -- 非アクティブなペインの明度を下げる
  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.6,
  },

  tab_bar_at_bottom = true,

  -- タブタイトルの設定
  tab_max_width = 32,

  automatically_reload_config = true,

  -- key bindings
  keys = {
    -- コピーモード
    {
      key = "v",
      mods = "CTRL|CMD",
      action = wezterm.action.ActivateCopyMode,
    },
    -- コピーモード (Cmd+Escでも起動可能)
    {
      key = "Escape",
      mods = "CMD",
      action = wezterm.action.ActivateCopyMode,
    },
    -- コピーモード (Cmd+[でも起動可能、vimライク)
    {
      key = "[",
      mods = "CMD",
      action = wezterm.action.ActivateCopyMode,
    },
    -- 検索モード
    {
      key = "f",
      mods = "CMD|SHIFT",
      action = wezterm.action.Search({ CaseSensitiveString = "" }),
    },
    -- QuickSelect モード (URL、パス、ハッシュなどを素早く選択)
    {
      key = "Space",
      mods = "CTRL|CMD",
      action = wezterm.action.QuickSelect,
    },
    -- ペイン移動 (vim風のhjkl)
    {
      key = "h",
      mods = "CMD",
      action = wezterm.action.ActivatePaneDirection("Left"),
    },
    {
      key = "j",
      mods = "CMD",
      action = wezterm.action.ActivatePaneDirection("Down"),
    },
    {
      key = "k",
      mods = "CMD",
      action = wezterm.action.ActivatePaneDirection("Up"),
    },
    {
      key = "l",
      mods = "CMD",
      action = wezterm.action.ActivatePaneDirection("Right"),
    },
    -- ペイン分割
    {
      key = "\\",
      mods = "CMD",
      action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
      key = "`",
      mods = "CMD",
      action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
      key = "w",
      mods = "CMD",
      action = wezterm.action_callback(function(window, pane)
        local process_name = pane:get_foreground_process_name()
        if process_name and process_name:find("nvim") then
          -- Neovimが動作中の場合、Ctrl+Wを送信
          window:perform_action({ SendKey = { key = "w", mods = "CTRL" } }, pane)
        else
          -- その他の場合は通常のタブクローズ
          window:perform_action(wezterm.action.CloseCurrentTab({ confirm = true }), pane)
        end
      end),
    },
    {
      key = "d",
      mods = "CMD",
      action = wezterm.action.CloseCurrentPane({ confirm = true }),
    },
    -- ペインサイズ変更
    {
      key = "h",
      mods = "CMD|SHIFT",
      action = wezterm.action.AdjustPaneSize({ "Left", 10 }),
    },
    {
      key = "j",
      mods = "CMD|SHIFT",
      action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
    },
    {
      key = "k",
      mods = "CMD|SHIFT",
      action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
    },
    {
      key = "l",
      mods = "CMD|SHIFT",
      action = wezterm.action.AdjustPaneSize({ "Right", 10 }),
    },
    -- フォントサイズ変更
    {
      key = "+",
      mods = "CMD|SHIFT",
      action = wezterm.action.IncreaseFontSize,
    },
    {
      key = "-",
      mods = "CMD",
      action = wezterm.action.DecreaseFontSize,
    },
    -- Workspace関連のキーバインド
    {
      key = "9",
      mods = "CMD",
      action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
    },
    {
      key = "n",
      mods = "CMD",
      action = wezterm.action.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Enter workspace name:" },
        }),
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              wezterm.action.SwitchToWorkspace({
                name = line,
              }),
              pane
            )
          end
        end),
      }),
    },
  },

  -- スクロールバックバッファのサイズ
  scrollback_lines = 10000,

  -- Copy modeのキーバインド (vimライク)
  key_tables = {
    copy_mode = {
      -- vimライクな移動
      { key = "h", mods = "NONE",  action = wezterm.action.CopyMode("MoveLeft") },
      { key = "j", mods = "NONE",  action = wezterm.action.CopyMode("MoveDown") },
      { key = "k", mods = "NONE",  action = wezterm.action.CopyMode("MoveUp") },
      { key = "l", mods = "NONE",  action = wezterm.action.CopyMode("MoveRight") },
      -- 単語移動
      { key = "w", mods = "NONE",  action = wezterm.action.CopyMode("MoveForwardWord") },
      { key = "b", mods = "NONE",  action = wezterm.action.CopyMode("MoveBackwardWord") },
      { key = "e", mods = "NONE",  action = wezterm.action.CopyMode("MoveForwardWordEnd") },
      -- 行頭・行末
      { key = "0", mods = "NONE",  action = wezterm.action.CopyMode("MoveToStartOfLine") },
      { key = "$", mods = "SHIFT", action = wezterm.action.CopyMode("MoveToEndOfLineContent") },
      { key = "^", mods = "SHIFT", action = wezterm.action.CopyMode("MoveToStartOfLineContent") },
      -- ページ移動
      { key = "g", mods = "NONE",  action = wezterm.action.CopyMode("MoveToScrollbackTop") },
      { key = "G", mods = "SHIFT", action = wezterm.action.CopyMode("MoveToScrollbackBottom") },
      { key = "d", mods = "CTRL",  action = wezterm.action.CopyMode("PageDown") },
      { key = "u", mods = "CTRL",  action = wezterm.action.CopyMode("PageUp") },
      -- ビジュアルモード
      { key = "v", mods = "NONE",  action = wezterm.action.CopyMode({ SetSelectionMode = "Cell" }) },
      { key = "V", mods = "SHIFT", action = wezterm.action.CopyMode({ SetSelectionMode = "Line" }) },
      {
        key = "v",
        mods = "CTRL",
        action = wezterm.action.CopyMode({ SetSelectionMode = "Block" }),
      },
      -- コピー
      {
        key = "y",
        mods = "NONE",
        action = wezterm.action.Multiple({
          { CopyTo = "ClipboardAndPrimarySelection" },
          { CopyMode = "Close" },
        }),
      },
      -- 検索
      { key = "/",      mods = "NONE",  action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
      { key = "n",      mods = "NONE",  action = wezterm.action.CopyMode("NextMatch") },
      { key = "N",      mods = "SHIFT", action = wezterm.action.CopyMode("PriorMatch") },
      -- 終了
      { key = "q",      mods = "NONE",  action = wezterm.action.CopyMode("Close") },
      { key = "Escape", mods = "NONE",  action = wezterm.action.CopyMode("Close") },
    },
  },
}
