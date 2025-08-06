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
    -- Only open if no files were specified on command line
    if vim.fn.argc() == 0 then
      -- Defer the command to ensure Neo-tree is loaded
      vim.defer_fn(function()
        vim.cmd("Neotree show")
      end, 100)
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