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
					-- File watchers can be heavy in very large repos; disable for performance
					use_libuv_file_watcher = false,
					-- 必要最低限の表示にするためのrenderers設定
					renderers = {
						directory = {
							{ "indent" },
							{ "icon" },
							{ "name" },
						},
						file = {
							{ "indent" },
							{ "icon" },
							{ "name" },
						},
					},
				},
				window = {
					mappings = {
						-- Open files in a proper buffer window, not in neo-tree
						["o"] = "open",
						["<CR>"] = "open",
						["l"] = "open",
						["h"] = "close_node",
					},
				},
				-- Ensure files are opened in the editor window, not in neo-tree
				open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
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
									if
										name == ""
										and #lines == 1
										and lines[1] == ""
										and not vim.bo[buf].modified
										and buf ~= vim.api.nvim_get_current_buf()
									then
										vim.api.nvim_buf_delete(buf, { force = true })
									end
								end
							end
						end,
					},
				},
			})
		end,
	}, -- Fuzzy finder
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
			{ "<leader>gc", "<cmd>Telescope git_status<cr>", desc = "Git changed files" },
			{ "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git files" },
		},
		config = function()
			local telescope = require("telescope")
			local search_ignore = require("config.search_ignore")
			local ignore_entries = search_ignore.entries()
			local ignore_patterns = search_ignore.patterns(ignore_entries)
			local has_fd = vim.fn.executable("fd") == 1
			-- Build commands for find_files depending on availability
			local find_cmd
			if has_fd then
				find_cmd = { "fd", "--type", "f", "--color", "never", "--hidden", "--strip-cwd-prefix" }
				vim.list_extend(find_cmd, search_ignore.fd_exclude_args(ignore_entries))
			else
				find_cmd = { "rg", "--files", "--hidden", "--follow" }
				vim.list_extend(find_cmd, search_ignore.rg_ignore_globs(ignore_entries))
			end

			telescope.setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
					file_ignore_patterns = ignore_patterns,
					preview = {
						line_numbers = true,
					},
					vimgrep_arguments = (function()
						local args = {
							"rg",
							"--color=never",
							"--no-heading",
							"--with-filename",
							"--line-number",
							"--column",
							"--smart-case",
							"--hidden",
							-- Uncomment to search .gitignored files (e.g., .log files):
							-- "--no-ignore-vcs",
						}
						vim.list_extend(args, search_ignore.rg_ignore_globs(ignore_entries))
						return args
					end)(),
				},
				pickers = {
					find_files = {
						find_command = find_cmd,
					},
					live_grep = {
						additional_args = function()
							local args = {
								"--hidden",
								-- Uncomment to search .gitignored files (e.g., .log files):
								-- "--no-ignore-vcs",
							}
							vim.list_extend(args, search_ignore.rg_ignore_globs(ignore_entries))
							return args
						end,
					},
					git_status = {
						git_icons = {
							added = "+",
							changed = "~",
							copied = "C",
							deleted = "-",
							renamed = "→",
							unmerged = "‡",
							untracked = "?",
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
			local search_ignore = require("config.search_ignore")
			local ignore_entries = search_ignore.entries()
			require("fzf-lua").setup({
				winopts = {
					split = "belowright new", -- 分割する場合は下に
				},
				lsp = {
					jump_to_single_result = true, -- 結果が1つの場合は自動ジャンプ
					ignore_current_line = true,
				},
				files = {
					fd_opts = (function()
						local opts = "--color=never --type f --hidden --follow"
						for _, entry in ipairs(ignore_entries) do
							opts = opts .. " --exclude " .. entry.pattern
						end
						return opts
					end)(),
					rg_opts = (function()
						-- Add "--no-ignore-vcs" to search .gitignored files (e.g., .log files)
						local opts = "--color=never --files --hidden --follow"
						for _, entry in ipairs(ignore_entries) do
							local suffix = entry.is_dir and "/**" or ""
							opts = opts .. " -g !" .. entry.pattern .. suffix
						end
						return opts
					end)(),
				},
				grep = {
					rg_opts = (function()
						-- Add "--no-ignore-vcs" to search .gitignored files (e.g., .log files)
						local opts = "--column --line-number --no-heading --color=never --smart-case --hidden"
						for _, entry in ipairs(ignore_entries) do
							local suffix = entry.is_dir and "/**" or ""
							opts = opts .. " -g !" .. entry.pattern .. suffix
						end
						return opts
					end)(),
				},
			})
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

}
