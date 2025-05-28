-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- 現在のファイルの相対パス（カレントディレクトリから）をクリップボードにコピー
vim.keymap.set("n", "<leader>cp", function()
  local relative_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", relative_path)
  print("Copied to clipboard: " .. relative_path)
end, { desc = "Copy relative path to clipboard" })
