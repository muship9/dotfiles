-- Colorscheme
return {
  {
    "rose-pine/neovim",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        styles = {
          transparency = false,
        },
        highlight_groups = {
          -- Visual mode selection
          Visual = { bg = "#6e6a86", fg = "#d5a8ff", bold = true }, -- 背景: 明るめグレー、文字: 明るい紫
          -- Visual mode (line selection)
          VisualNOS = { bg = "#6e6a86", fg = "#d5a8ff", bold = true },
          -- Yank ハイライト
          IncSearch = { bg = "#6e6a86", fg = "#d5a8ff", bold = true }, -- yank時のハイライト
          -- Git diff の色を濃くする
          DiffAdd = { bg = "#1a3a1a", fg = "#9ccfd8" },                -- 追加行: 濃い緑背景
          DiffDelete = { bg = "#3a1a1a", fg = "#eb6f92" },             -- 削除行: 濃い赤背景
        },
      })
      vim.cmd([[colorscheme rose-pine]])

      -- Set terminal colors to match rose-pine palette (same as wezterm)
      vim.g.terminal_color_0 = "#26233a"  -- black
      vim.g.terminal_color_1 = "#eb6f92"  -- red
      vim.g.terminal_color_2 = "#31748f"  -- green
      vim.g.terminal_color_3 = "#f6c177"  -- yellow
      vim.g.terminal_color_4 = "#9ccfd8"  -- blue
      vim.g.terminal_color_5 = "#c4a7e7"  -- magenta
      vim.g.terminal_color_6 = "#ebbcba"  -- cyan
      vim.g.terminal_color_7 = "#e0def4"  -- white
      vim.g.terminal_color_8 = "#6e6a86"  -- bright black
      vim.g.terminal_color_9 = "#eb6f92"  -- bright red
      vim.g.terminal_color_10 = "#31748f" -- bright green
      vim.g.terminal_color_11 = "#f6c177" -- bright yellow
      vim.g.terminal_color_12 = "#9ccfd8" -- bright blue
      vim.g.terminal_color_13 = "#c4a7e7" -- bright magenta
      vim.g.terminal_color_14 = "#ebbcba" -- bright cyan
      vim.g.terminal_color_15 = "#e0def4" -- bright white
    end,
  },
}
