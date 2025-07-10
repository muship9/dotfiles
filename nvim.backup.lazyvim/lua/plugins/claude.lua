-- 設定例：キーマップにコメントを日本語で
return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("claude-code").setup({
      window = {
        split_ratio = 0.3, -- 画面の50%を使用
        position = "vertical", -- 垂直分割
        enter_insert = true,
        hide_numbers = true,
        hide_signcolumn = true,
      },
    })
    -- 日本語コメント付きキーマップ
    vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<CR>", { desc = "Claude Codeを開く" })
  end,
}
