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

-- LazyGit 実行中は診断を一時停止して負荷を軽減
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("lazygit_perf"),
  pattern = "term://*lazygit*",
  callback = function()
    vim.g.__lazygit_terms = (vim.g.__lazygit_terms or 0) + 1
    if vim.g.__lazygit_terms == 1 then
      -- グローバルに診断を停止
      pcall(vim.diagnostic.disable)
    end
  end,
})

vim.api.nvim_create_autocmd({ "TermClose", "BufWipeout" }, {
  group = augroup("lazygit_perf_restore"),
  pattern = "term://*lazygit*",
  callback = function()
    if vim.g.__lazygit_terms and vim.g.__lazygit_terms > 0 then
      vim.g.__lazygit_terms = vim.g.__lazygit_terms - 1
      if vim.g.__lazygit_terms == 0 then
        -- 元に戻す
        pcall(vim.diagnostic.enable)
      end
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

-- 大規模ファイルの検出と最適化
vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
  group = augroup("large_file_detect"),
  callback = function(args)
    local max_filesize = 1024 * 1024 * 2 -- 2MB
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
      
      vim.notify("Large file detected. Some features disabled for performance.", vim.log.levels.INFO)
    end
  end,
})

-- TypeScript/JavaScript ファイル用の追加設定
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("typescript_settings"),
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function(args)
    -- 大規模ファイルの場合は診断を遅延
    if vim.b[args.buf].large_file then
      vim.diagnostic.config({
        virtual_text = false,
        update_in_insert = false,
        underline = false,
      }, args.buf)
    end
  end,
})
