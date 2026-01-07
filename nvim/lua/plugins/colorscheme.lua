-- Colorscheme
return {
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				transparent = true,
				compile = false,
			})
			vim.cmd("colorscheme kanagawa-wave")
		end,
	},
}
