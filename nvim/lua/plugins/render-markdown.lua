return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  opts = {
    heading = {
      position = 'inline',
      icons = { '1. ', '2. ', '3. ', '4. ', '5. ', '6. ' },
    },
    bullet = {
      icons = { '·' },
    },
  },
}
