-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
local g = vim.g

opt.relativenumber = false -- 絶対行番号を使用
opt.hidden = true -- 非表示のバッファに切り替えを許可

g.nvim_tree_hide_dotfiles = 0 -- nvim-treeでドットファイルを表示

