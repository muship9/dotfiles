---- 相対パスをクリップボードにコピー
vim.keymap.set("n", "<leader>cp", function()
  local rel_path = vim.fn.expand("%:.")
  vim.fn.setreg("+", rel_path)
  vim.notify("Copy FilePath: " .. rel_path)
end, { desc = "Copy FilePath" })
