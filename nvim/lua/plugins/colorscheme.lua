-- Colorscheme
return {
  {
    "rose-pine/neovim",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        highlight_groups = {
          -- Visual mode selection
          Visual = { bg = "#6e6a86", fg = "#e0def4" },
          -- Visual mode (line selection)
          VisualNOS = { bg = "#6e6a86", fg = "#e0def4" },
        },
      })
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}
