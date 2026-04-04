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
		end,
	},
}
