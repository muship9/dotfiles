return {
  "petertriho/nvim-scrollbar",
  event = { "BufNewFile", "BufReadPre" },
  dependencies = {
    "kevinhwang91/nvim-hlslens",
    "lewis6991/gitsigns.nvim",
    "sho-87/kanagawa-paper.nvim", -- 依存関係を明示
  },
  config = function()
    -- 安全にモジュールを読み込む
    local status, colors_module = pcall(require, "kanagawa-paper.colors")
    local colors
    if status and type(colors_module.load) == "function" then
      colors = colors_module.load()
    else
      -- フォールバック：デフォルトカラーを定義
      colors = {
        bg_highlight = "#2D4F67",
        orange = "#FFA066",
        error = "#E82424",
        warn = "#FF9E3B",
        info = "#658594",
        hint = "#6A9589",
        purple = "#957FB8",
      }
    end

    require("scrollbar").setup({
      handle = {
        color = colors.bg_highlight,
      },
      marks = {
        Search = { color = colors.orange },
        Error = { color = colors.error },
        Warn = { color = colors.warn },
        Info = { color = colors.info },
        Hint = { color = colors.hint },
        Misc = { color = colors.purple },
      },
    })
    require("scrollbar.handlers.gitsigns").setup()
  end,
}
