-- Basic options
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = false

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Behavior
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- File handling
opt.fixeol = true  -- Automatically add newline at end of file when saving
opt.eol = true     -- Keep end-of-line character

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
opt.lazyredraw = false

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Command line settings
opt.cmdheight = 0  -- Hide command line when not in use
opt.laststatus = 3  -- Global statusline
opt.showmode = false  -- Don't show mode since we have statusline
opt.showcmd = false  -- Don't show command in status line
opt.ruler = false  -- Don't show cursor position in command line

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Suppress deprecation warnings from plugins
vim.deprecate = function() end

-- Set up Neovim server for neovim-remote (nvr)
-- This ensures that v:servername is set properly
if vim.fn.has("nvim") == 1 then
  -- Set servername if not already set
  if vim.v.servername == "" then
    -- Use a unique servername based on PID
    vim.v.servername = "/tmp/nvim-" .. vim.fn.getpid() .. ".sock"
  end
  -- Export NVIM environment variable for child processes
  vim.env.NVIM = vim.v.servername
end