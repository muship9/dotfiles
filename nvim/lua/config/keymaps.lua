-- Basic keymaps
local keymap = vim.keymap.set

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "左のウィンドウへ移動" })
keymap("n", "<C-j>", "<C-w>j", { desc = "下のウィンドウへ移動" })
keymap("n", "<C-k>", "<C-w>k", { desc = "上のウィンドウへ移動" })
keymap("n", "<C-l>", "<C-w>l", { desc = "右のウィンドウへ移動" })

-- Window split with hjkl
keymap("n", "<leader>wh", "<C-W>v<C-W>h", { desc = "垂直分割（左）" })
keymap("n", "<leader>wj", "<C-W>s", { desc = "水平分割（下）" })
keymap("n", "<leader>wk", "<C-W>s<C-W>k", { desc = "水平分割（上）" })
keymap("n", "<leader>wl", "<C-W>v", { desc = "垂直分割（右）" })

-- Resize window using <ctrl> arrow keys
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "ウィンドウの高さを増やす" })
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "ウィンドウの高さを減らす" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "ウィンドウの幅を減らす" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "ウィンドウの幅を増やす" })

-- Move Lines
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "行を下へ移動" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "行を上へ移動" })
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "行を下へ移動" })
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "行を上へ移動" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "行を下へ移動" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "行を上へ移動" })

-- Clear search with <esc>
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "検索ハイライトをクリア" })

-- Better indenting
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Save file
keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "ファイルを保存" })

-- Help
keymap("n", "<leader>h", "<cmd>Telescope keymaps<cr>", { desc = "キーマップ一覧を表示" })

-- Quit
keymap("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "すべて強制終了" })
keymap("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "すべて保存して終了" })
keymap("n", "<leader>qa", "<cmd>qa<cr>", { desc = "すべて終了" })

-- Windows
keymap("n", "<leader>ww", "<C-W>p", { desc = "前のウィンドウへ" })
keymap("n", "<leader>wd", "<C-W>c", { desc = "ウィンドウを削除" })

-- Buffers
keymap("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "左のタブへ移動" })
keymap("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "右のタブへ移動" })
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "前のバッファ" })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "次のバッファ" })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "直前のバッファへ切り替え" })
keymap("n", "<leader>`", "<cmd>e #<cr>", { desc = "直前のバッファへ切り替え" })
local function smart_close_buffer()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()

  local current_ft = vim.bo[current_buf].filetype
  if current_ft == "neo-tree" or current_ft == "aerial" or current_ft == "toggleterm" then
    return
  end

  local force_delete = false
  if vim.bo[current_buf].modified then
    local choice = vim.fn.confirm("未保存の変更があります。どうしますか?", "&Save\n&Discard\n&Cancel", 1)
    if choice == 1 then
      local ok, err = pcall(vim.cmd, "write")
      if not ok then
        vim.notify("保存に失敗しました: " .. err, vim.log.levels.ERROR)
        return
      end
    elseif choice == 2 then
      force_delete = true
    else
      return
    end
  end

  -- Diffビューでは before 側のバッファだけをクリーンアップ
  if vim.wo.diff then
    local diff_entries = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" and vim.api.nvim_win_get_option(win, "diff") then
        diff_entries[#diff_entries + 1] = { win = win, buf = vim.api.nvim_win_get_buf(win) }
      end
    end

    local function is_before_buffer(bufnr)
      if bufnr == current_buf then
        return false
      end
      if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
        return false
      end
      local bo = vim.bo[bufnr]
      if not bo.buflisted then
        return true
      end
      if bo.buftype ~= "" then
        return true
      end
      if bo.modifiable == false then
        return true
      end
      return false
    end

    local targets = {}
    local closing_current = false
    for _, entry in ipairs(diff_entries) do
      if is_before_buffer(entry.buf) then
        targets[#targets + 1] = entry
        if entry.win == current_win then
          closing_current = true
        end
      end
    end

    if #targets > 0 then
      if closing_current then
        local fallback_win
        for _, entry in ipairs(diff_entries) do
          if entry.win ~= current_win and not is_before_buffer(entry.buf) then
            fallback_win = entry.win
            break
          end
        end
        if not fallback_win then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" and win ~= current_win then
              fallback_win = win
              break
            end
          end
        end
        if fallback_win then
          vim.api.nvim_set_current_win(fallback_win)
        end
      end

      pcall(vim.cmd, "diffoff!")

      for _, entry in ipairs(targets) do
        if vim.api.nvim_buf_is_valid(entry.buf) and vim.api.nvim_buf_is_loaded(entry.buf) then
          local ok, err = pcall(vim.api.nvim_buf_delete, entry.buf, { force = true })
          if not ok then
            vim.notify("バッファ削除に失敗しました: " .. err, vim.log.levels.ERROR)
          end
        end
        if vim.api.nvim_win_is_valid(entry.win) then
          pcall(vim.api.nvim_win_close, entry.win, true)
        end
      end

      return
    end

    pcall(vim.cmd, "diffoff!")
  end

  local target_wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local win_config = vim.api.nvim_win_get_config(win)
    if buf == current_buf and ft ~= "neo-tree" and ft ~= "aerial" and ft ~= "toggleterm" and win_config.relative == "" then
      target_wins[#target_wins + 1] = win
    end
  end

  local alternate_buf = vim.fn.bufnr("#")

  local function is_normal_buffer(bufnr)
    if bufnr == -1 or not vim.api.nvim_buf_is_loaded(bufnr) or not vim.bo[bufnr].buflisted then
      return false
    end
    local ft = vim.bo[bufnr].filetype
    return ft ~= "neo-tree" and ft ~= "aerial" and ft ~= "toggleterm"
  end

  local switched = false
  if is_normal_buffer(alternate_buf) and alternate_buf ~= current_buf then
    local ok, err = pcall(vim.cmd, "buffer " .. alternate_buf)
    if ok then
      switched = true
    else
      vim.notify("バッファ切替に失敗しました: " .. err, vim.log.levels.ERROR)
    end
  end

  if not switched then
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if is_normal_buffer(bufnr) and bufnr ~= current_buf then
        local ok, err = pcall(vim.cmd, "buffer " .. bufnr)
        if ok then
          switched = true
          break
        else
          vim.notify("バッファ切替に失敗しました: " .. err, vim.log.levels.ERROR)
        end
      end
    end
  end

  if not switched then
    local ok, err = pcall(vim.cmd, "enew")
    if not ok then
      vim.notify("新しいバッファを開けません: " .. err, vim.log.levels.ERROR)
      return
    end
  end

  local replacement_buf = vim.api.nvim_get_current_buf()

  for _, win in ipairs(target_wins) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == current_buf then
      pcall(vim.api.nvim_win_set_buf, win, replacement_buf)
    end
  end

  local success, err = pcall(vim.api.nvim_buf_delete, current_buf, { force = force_delete })
  if not success then
    vim.notify("バッファ削除に失敗しました: " .. err, vim.log.levels.ERROR)
  end

  vim.schedule(function()
    if not vim.api.nvim_win_is_valid(current_win) then
      return
    end
    local cur_win = vim.api.nvim_get_current_win()
    local cur_buf = vim.api.nvim_win_get_buf(cur_win)
    local cur_ft = vim.bo[cur_buf].filetype

    if cur_ft == "neo-tree" or cur_ft == "aerial" or cur_ft == "toggleterm" then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        if ft ~= "neo-tree" and ft ~= "aerial" and ft ~= "toggleterm" then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end
  end)
end

keymap("n", "<leader>w", smart_close_buffer, { desc = "バッファを削除（スマート）" })

-- Command+W support (mapped through Wezterm as Ctrl+Shift+W)
keymap("n", "<C-S-w>", smart_close_buffer, { desc = "バッファを削除（Ctrl+Shift+W）" })

-- Copy relative path from cwd
keymap("n", "<leader>cp", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    print("No file in buffer")
    return
  end

  local cwd = vim.fn.getcwd()
  local relative_path = vim.fn.fnamemodify(file_path, ":s?" .. cwd .. "/??")
  vim.fn.setreg("+", relative_path)
  print("Copied: " .. relative_path)
end, { desc = "cwdからの相対パスをコピー" })

keymap("n", "<leader>pm", function()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    vim.notify("ファイルが保存されていません", vim.log.levels.WARN)
    return
  end

  if vim.fn.filereadable(file_path) == 0 then
    vim.notify("ファイルを読み込めません: " .. file_path, vim.log.levels.ERROR)
    return
  end

  if vim.fn.expand("%:e") ~= "md" then
    vim.notify("Markdown ファイルではありません", vim.log.levels.WARN)
    return
  end

  local job = vim.fn.jobstart({ "open", "-a", "Vivaldi", file_path }, { detach = true })
  if job <= 0 then
    vim.notify("Vivaldi を起動できませんでした", vim.log.levels.ERROR)
  end
end, { desc = "Vivaldi で Markdown をプレビュー" })

-- Jump to matching tag/bracket
keymap("n", "gt", "%", { desc = "対応するタグ・括弧へジャンプ" })
keymap("v", "gt", "%", { desc = "対応するタグ・括弧へジャンプ" })

-- Git blame toggle is handled by blamer.nvim plugin
-- Use <leader>gb to toggle inline git blame display

-- Open current file in GitHub
keymap("n", "<leader>gB", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    print("No file in buffer")
    return
  end
  
  -- Get git root
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not in a git repository")
    return
  end
  
  -- Get current branch
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
  if vim.v.shell_error ~= 0 then
    print("Failed to get current branch")
    return
  end
  
  -- Get remote URL
  local remote_url = vim.fn.systemlist("git config --get remote.origin.url")[1]
  if vim.v.shell_error ~= 0 then
    print("No remote origin found")
    return
  end
  
  -- Convert SSH URL to HTTPS if needed
  remote_url = remote_url:gsub("^git@github%.com:", "https://github.com/")
  remote_url = remote_url:gsub("%.git$", "")
  
  -- Get relative path from git root
  local relative_path = vim.fn.fnamemodify(file_path, ":s?" .. git_root .. "/??")
  
  -- Get current line number
  local line = vim.fn.line(".")
  
  -- Construct GitHub URL
  local github_url = string.format("%s/blob/%s/%s#L%d", remote_url, branch, relative_path, line)
  
  -- Open in browser
  local open_cmd
  if vim.fn.has("mac") == 1 then
    open_cmd = "open"
  elseif vim.fn.has("unix") == 1 then
    open_cmd = "xdg-open"
  elseif vim.fn.has("win32") == 1 then
    open_cmd = "start"
  else
    print("Unsupported OS")
    return
  end
  
  vim.fn.system(string.format("%s %s", open_cmd, vim.fn.shellescape(github_url)))
  print("Opened in GitHub: " .. github_url)
end, { desc = "現在のファイルをGitHubで開く" })


-- LSP デバッグ・管理用キーマップ
keymap("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "LSPサーバーを再起動" })
keymap("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP情報を表示" })
keymap("n", "<leader>ll", function()
	vim.cmd("edit " .. vim.lsp.get_log_path())
end, { desc = "LSPログを開く" })
keymap("n", "<leader>ld", function()
	print("=== LSP Debug Info ===")
	print("Filetype: " .. vim.bo.filetype)
	local clients = vim.lsp.get_active_clients({ bufnr = 0 })
	if #clients == 0 then
		print("No LSP clients attached")
	else
		for _, client in ipairs(clients) do
			print(string.format("Client: %s (id: %d)", client.name, client.id))
		end
	end
end, { desc = "LSPデバッグ情報を表示" })
