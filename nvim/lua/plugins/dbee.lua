return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    -- 自動検出が失敗した場合、特定の方法を指定
    require("dbee").install("curl")
  end,
  config = function()
    require("dbee").setup({
      -- 必要に応じて設定をカスタマイズ
    })
  end,
}
