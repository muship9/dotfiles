return {
  -- add kanagawa
  { "rebelot/kanagawa.nvim" },
  { "sho-87/kanagawa-paper.nvim" },

  -- Configure LazyVim to load kanagawa
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "kanagawa",
      colorscheme = "kanagawa-paper",
    },
  },
}

