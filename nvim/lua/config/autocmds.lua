-- Autocmds
local function augroup(name)
  return vim.api.nvim_create_augroup("minimal_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Auto open Neo-tree on startup
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("auto_open_tree"),
  callback = function()
    -- 環境変数で明示的に有効化された場合のみ自動オープンする
    if vim.env.DOTFILES_AUTO_OPEN_TREE == "1" and vim.fn.argc() == 0 then
      vim.defer_fn(function()
        pcall(vim.cmd, "Neotree show")
      end, 100)
    end
  end,
})

-- LazyGit ターミナルバッファのみ診断を無効化（グローバルは無効化しない）
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("lazygit_perf"),
  pattern = "term://*lazygit*",
  callback = function(args)
    -- ターミナルバッファに限定して診断を無効化
    pcall(vim.diagnostic.disable, { bufnr = args.buf })
    vim.b[args.buf].__diagnostic_was_enabled = true
    vim.notify("LazyGit ターミナルで診断を無効化（他バッファは影響なし）", vim.log.levels.DEBUG)
  end,
})

vim.api.nvim_create_autocmd({ "TermClose", "BufWipeout" }, {
  group = augroup("lazygit_perf_restore"),
  pattern = "term://*lazygit*",
  callback = function(args)
    if vim.b[args.buf] and vim.b[args.buf].__diagnostic_was_enabled then
      -- 念のため対象バッファにのみ再度有効化（バッファ終端時なので実質不要）
      pcall(vim.diagnostic.enable, { bufnr = args.buf })
      vim.b[args.buf].__diagnostic_was_enabled = nil
      vim.notify("LazyGit ターミナルの診断設定を後始末", vim.log.levels.DEBUG)
    end
  end,
})

-- Start Neovim server for nvr (neovim-remote support)
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("nvim_server"),
  callback = function()
    -- Set up server for neovim-remote if not already running
    if vim.v.servername == "" then
      local server_address = vim.env.NVIM_LISTEN_ADDRESS or "/tmp/nvim.pipe"
      
      -- Try to start the server
      local ok, result = pcall(vim.fn.serverstart, server_address)
      if ok and result ~= "" then
        -- Server started successfully, set environment variable for child processes
        vim.env.NVIM = result
        vim.notify("Neovim server started: " .. result, vim.log.levels.DEBUG)
      else
        -- Fallback to PID-based server name
        local fallback_address = "/tmp/nvim-" .. vim.fn.getpid() .. ".sock"
        local fallback_ok, fallback_result = pcall(vim.fn.serverstart, fallback_address)
        if fallback_ok and fallback_result ~= "" then
          vim.env.NVIM = fallback_result
          vim.notify("Neovim server started (fallback): " .. fallback_result, vim.log.levels.DEBUG)
        end
      end
    else
      -- Server already running, ensure NVIM env var is set
      vim.env.NVIM = vim.v.servername
    end
  end,
})

-- 大規模ファイルの検出と最適化（改善版）
vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
  group = augroup("large_file_detect"),
  callback = function(args)
    local max_filesize = 1024 * 1024 * 8 -- 8MBに増加（TypeScript診断への影響を減らすため）
    local ok, stats = pcall(vim.loop.fs_stat, args.file)
    
    if ok and stats and stats.size > max_filesize then
      -- 大規模ファイル用の設定を適用
      vim.b.large_file = true
      
      -- syntax highlightingを制限
      vim.cmd("syntax off")
      vim.opt_local.wrap = false
      vim.opt_local.spell = false
      vim.opt_local.undofile = false
      vim.opt_local.swapfile = false
      vim.opt_local.relativenumber = false
      
      -- folding を無効化
      vim.opt_local.foldenable = false
      
      -- 長い行のためのsynmaxcolを設定
      vim.opt_local.synmaxcol = 120
      
      vim.notify(string.format("大規模ファイル検出 (%.1fMB). パフォーマンスのため一部機能を無効化", stats.size / (1024 * 1024)), vim.log.levels.INFO)
    end
  end,
})

-- TypeScript/JavaScript ファイル用の追加設定（安全版）
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("typescript_settings"),
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function(args)
    -- 診断サインの定義を確実に行う
    pcall(vim.fn.sign_define, "DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
    pcall(vim.fn.sign_define, "DiagnosticSignWarn", { text = "⚠", texthl = "DiagnosticSignWarn" })
    pcall(vim.fn.sign_define, "DiagnosticSignInfo", { text = "ⓘ", texthl = "DiagnosticSignInfo" })
    pcall(vim.fn.sign_define, "DiagnosticSignHint", { text = "💡", texthl = "DiagnosticSignHint" })
    
    -- LSPがアタッチされるまで少し待つ
    vim.defer_fn(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end
    
    -- 大規模ファイルの場合は診断を軽量化（完全無効化はしない）
    if vim.b[args.buf].large_file then
      local ok, err = pcall(vim.diagnostic.config, {
        virtual_text = {
          -- エラーと警告のみ表示
          severity = { min = vim.diagnostic.severity.WARN },
          prefix = "●",
          spacing = 4,
        },
        signs = {
          -- エラーと警告のみ表示
          severity = { min = vim.diagnostic.severity.WARN },
        },
        update_in_insert = false,
        underline = {
          -- エラーのみ下線表示
          severity = { min = vim.diagnostic.severity.ERROR },
        },
        -- フロート表示は通常通り
        float = {
          focusable = true,
          style = "minimal",
          border = "none",
        },
      }, args.buf)
      
      if not ok then
        vim.notify("大規模ファイル用診断設定でエラー: " .. tostring(err), vim.log.levels.WARN)
      end
    else
      -- 通常サイズのファイルでは完全な診断設定を適用
      -- namespace の問題を回避するため、エラーハンドリング付きで設定
      local ok, err = pcall(vim.diagnostic.config, {
        virtual_text = {
          prefix = "●",
          spacing = 4,
          severity = nil, -- すべてのレベルを表示
        },
        signs = {
          severity = nil, -- すべてのレベルを表示  
        },
        update_in_insert = false,
        underline = {
          severity = nil, -- すべてのレベルを表示
        },
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "none",
        },
      }, args.buf)
      
      if not ok then
        -- エラーが発生した場合はグローバル設定にフォールバック
        vim.notify("バッファ固有の診断設定でエラー: " .. tostring(err), vim.log.levels.WARN)
      end
      
      -- 診断が強制的に有効になっていることを確認
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          pcall(vim.diagnostic.show, nil, args.buf)
        end
      end)
    end
    end, 300) -- 300ms遅延してLSPアタッチを待つ
  end,
})
