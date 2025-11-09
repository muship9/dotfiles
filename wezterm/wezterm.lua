local wezterm = require("wezterm")

-- Obsidian vault paths
local HOME = os.getenv("HOME")
local OBS_VAULT = HOME .. "/Documents/Obsidian Vault"
local OBS_DAILY = OBS_VAULT .. "/daily"

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
  font = wezterm.font("JetBrains Mono", { weight = "Medium", italic = true }),
  font_size = 14.0,

  window_background_opacity = 0.85,

  -- color scheme
  color_scheme = "rose-pine",

  -- 選択範囲の色を見やすくカスタマイズ
  colors = {
    background = "#191724", -- rose-pine の標準 base に戻す
    selection_bg = "#6e6a86", -- 明るめグレー (nvim と統一)
    selection_fg = "#d5a8ff", -- 明るい紫 (nvim と統一)
    -- コピーモードとQuickSelectモードでのハイライト
    copy_mode_active_highlight_bg = { Color = "#c4a7e7" }, -- rose-pine の iris (紫)
    copy_mode_active_highlight_fg = { Color = "#191724" }, -- 標準 base
    copy_mode_inactive_highlight_bg = { Color = "#6e6a86" }, -- 非アクティブなマッチ
    copy_mode_inactive_highlight_fg = { Color = "#e0def4" },
    quick_select_label_bg = { Color = "#9ccfd8" }, -- rose-pine の foam (青緑)
    quick_select_label_fg = { Color = "#191724" },
    quick_select_match_bg = { Color = "#6e6a86" }, -- overlay より明るめの紫
    quick_select_match_fg = { Color = "#e0def4" },
  },

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
    -- Obsidian連携：選択範囲または現在行をデイリーノートに追加
    {
      key = "y",
      mods = "CMD|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        local content = ""
        local content_type = ""

        -- 選択範囲を取得
        local selection = window:get_selection_text_for_pane(pane)
        if selection and selection ~= "" then
          content = selection
          content_type = "selection"
        else
          -- 選択範囲がない場合は現在行を取得
          -- カーソル位置を取得してその行を選択
          window:perform_action(wezterm.action.SelectTextAtMouseCursor("Line"), pane)
          -- 少し待ってから選択範囲を取得
          wezterm.sleep_ms(50)
          local line_selection = window:get_selection_text_for_pane(pane)
          if line_selection and line_selection ~= "" then
            content = line_selection:gsub("^%s+", ""):gsub("%s+$", "") -- 前後の空白を削除
            content_type = "current line"
            -- 選択を解除
            window:perform_action(wezterm.action.ClearSelection, pane)
          end
        end

        if content ~= "" then
          -- 正規化とパスを準備
          content = content:gsub("\r\n", "\n"):gsub("\r", "\n")
          local timestamp = os.date("%H:%M")
          local daily_file = OBS_DAILY .. "/" .. os.date("%Y-%m-%d") .. ".md"

          -- ディレクトリ作成 + まとめて追記
          local cmd = string.format(
            [[/bin/bash -lc 'set -e; mkdir -p %q; { echo; echo "---"; echo %q; echo %q; } >> %q']],
            OBS_DAILY,
            timestamp,
            content:gsub("'", "'\\''"),
            daily_file
          )
          local result = os.execute(cmd)
          if result == 0 then
            window:toast_notification("Wezterm", "Added " .. content_type .. " to daily note (" .. timestamp .. ")", nil,
              3000)
          else
            window:toast_notification("Wezterm", "Failed to add to daily note", nil, 3000)
          end
        else
          window:toast_notification("Wezterm", "No content to add", nil, 3000)
        end
      end),
    },
  },
}
