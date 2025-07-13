-- Editor plugins
return {
	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		lazy = false,
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
			{ "<leader>o", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in Neo-tree" },
		},
		config = function()
			require("neo-tree").setup({
				filesystem = {
					filtered_items = {
						visible = true,
						hide_dotfiles = false,
						hide_gitignored = false,
					},
					follow_current_file = {
						enabled = true, -- This will find and focus the file in the active buffer every time
						leave_dirs_open = true, -- `false` closes auto expanded dirs when navigating
					},
					use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
				},
				window = {
					mappings = {
						["o"] = "open",
					},
				},
				event_handlers = {
					{
						event = "file_opened",
						handler = function(file_path)
							-- Auto close empty buffers when opening a file from neo-tree
							local buffers = vim.api.nvim_list_bufs()
							for _, buf in ipairs(buffers) do
								if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
									local name = vim.api.nvim_buf_get_name(buf)
									local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
									-- Delete empty unnamed buffers (but not the current buffer)
									if name == "" and #lines == 1 and lines[1] == "" and not vim.bo[buf].modified 
										and buf ~= vim.api.nvim_get_current_buf() then
										vim.api.nvim_buf_delete(buf, { force = true })
									end
								end
							end
						end,
					},
				},
			})
		end,
	},

	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep in project" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
			})
		end,
	},

	-- FzfLua for better fuzzy finding
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("fzf-lua").setup({})
		end,
	},

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0,
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})

			-- Integration with cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = "ToggleTerm",
		keys = {
			{ "<C-/>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		},
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<c-/>]],
				direction = "float",
				float_opts = {
					border = "curved",
				},
			})
		end,
	},

	-- Lazygit integration
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
}