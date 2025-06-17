return {
  -- null-lsを使ってPrettierを設定
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local null_ls = require("null-ls")
      opts.sources = opts.sources or {} -- opts.sourcesがnilの場合に空のテーブルとして初期化
      -- Prettierを追加
      table.insert(opts.sources, null_ls.builtins.formatting.prettier)
    end,
  },
}
