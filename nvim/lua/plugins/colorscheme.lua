-- Colorscheme
return {
  -- {
  -- 	"rebelot/kanagawa.nvim",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	config = function()
  -- 		require("kanagawa").setup({
  -- 			transparent = true,
  -- 			compile = false,
  -- 		})
  -- 		vim.cmd("colorscheme kanagawa-wave")
  -- 	end,
  -- },
  {
    "Aejkatappaja/sora",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
    config = function(_, opts)
      require("sora").setup(opts)
      vim.cmd("colorscheme sora")

      local function apply_custom_highlights()
        -- git blame (GitSignsCurrentLineBlame) をソラパレットに合わせて調整
        vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#586478", italic = true })

        -- @module / @variable.member / @operator をコメント色と区別できるよう明るく
        vim.api.nvim_set_hl(0, "@module",                { fg = "#c8d0e0" })
        vim.api.nvim_set_hl(0, "@module.builtin",        { fg = "#c8d0e0", italic = true })
        vim.api.nvim_set_hl(0, "@variable.member",       { fg = "#c8d0e0" })
        vim.api.nvim_set_hl(0, "@operator",              { fg = "#c8d0e0" })

        -- Telescope: transparent時に真っ黒になる浮動ウィンドウをbg_elevatedで統一
        vim.api.nvim_set_hl(0, "TelescopeNormal",          { fg = "#c8d0e0", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopePreviewNormal",   { fg = "#c8d0e0", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopeResultsNormal",   { fg = "#c8d0e0", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopePromptNormal",    { fg = "#c8d0e0", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopeBorder",          { fg = "#222838", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder",   { fg = "#222838", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder",   { fg = "#222838", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder",    { fg = "#222838", bg = "#14161e" })
        vim.api.nvim_set_hl(0, "TelescopePromptTitle",     { fg = "#80c8e0", bg = "#14161e", bold = true })
        vim.api.nvim_set_hl(0, "TelescopePreviewTitle",    { fg = "#80c8e0", bg = "#14161e", bold = true })
        vim.api.nvim_set_hl(0, "TelescopeResultsTitle",    { fg = "#80c8e0", bg = "#14161e", bold = true })
        vim.api.nvim_set_hl(0, "TelescopeSelection",       { bg = "#1e2430" })
        vim.api.nvim_set_hl(0, "TelescopeSelectionCaret",  { fg = "#80c8e0", bg = "#1e2430" })
      end

      apply_custom_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "sora",
        callback = apply_custom_highlights,
      })
    end,
  },
}
