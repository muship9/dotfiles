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
	font = wezterm.font("JetBrains Mono", { weight = "Medium", italic = true }),
	font_size = 14.0,

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
			key = "l",
			mods = "CMD",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "h",
			mods = "CMD",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "j",
			mods = "CMD",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "k",
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
			key = "w",
			mods = "CMD|SHIFT",
			action = wezterm.action.CloseCurrentPane({ confirm = true }),
		},
	},
}
