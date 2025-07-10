-- Prettierタイムアウト問題の修正
return {
  -- conform.nvimの設定を更新
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 5000, -- タイムアウトを5秒に増加
        lsp_fallback = true,
        async = false, -- 同期的に実行
        quiet = false, -- エラーを表示
      },
      format_after_save = false, -- 保存後の非同期フォーマットを無効化
      formatters = {
        prettier = {
          prepend_args = { "--cache", "--cache-strategy", "content" }, -- キャッシュを有効化
        },
      },
    },
  },
  
  -- null-lsのPrettierを無効化（conform.nvimと重複を避ける）
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local null_ls = require("null-ls")
      opts.sources = opts.sources or {}
      -- Prettierを削除（conform.nvimで管理）
      for i, source in ipairs(opts.sources) do
        if source.name == "prettier" then
          table.remove(opts.sources, i)
          break
        end
      end
      return opts
    end,
  },
}