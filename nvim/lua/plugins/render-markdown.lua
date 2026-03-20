return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  opts = {
    heading = {
      sign = false,
      icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      backgrounds = { "", "", "", "", "", "" }, -- 背景なし
    },
    bullet = {
      icons = { "●", "○", "◆", "◇" },
    },
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
    dash = {
      icon = "─",
      width = "full",
    },
    link = {
      enabled = true,
    },
  },
}
