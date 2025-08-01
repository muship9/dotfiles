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
		config = function()
			-- Set NVIM environment variable for neovim-remote
			-- Find the first available nvr executable
local nvr_paths = {
    "/opt/homebrew/bin/nvr",
    "/Users/SHINP09/Library/Python/3.9/bin/nvr"
}
local nvr_binary = nil
for _, path in ipairs(nvr_paths) do
    if vim.fn.executable(path) == 1 then
        nvr_binary = path
        break
    end
end
vim.g.lazygit_nvim_remote_binary = nvr_binary or ""
			vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
			vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
			vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" } -- customize lazygit popup window border characters
			vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
			vim.g.lazygit_use_neovim_remote = 1 -- Use neovim remote for terminal buffer
			vim.g.lazygit_use_custom_config_file_path = 1 -- Use custom config file
			vim.g.lazygit_config_file_path = vim.fn.expand("~/.config/lazygit/config.yml") -- Path to config file

			-- Ensure proper environment setup before opening lazygit
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*lazygit",
				callback = function()
					-- Ensure NVIM environment variable is set for neovim-remote
					local servername = vim.v.servername
					if servername and servername ~= "" then
						vim.fn.setenv("NVIM", servername)
						-- Also set GIT_EDITOR to use nvr
						vim.fn.setenv(
							"GIT_EDITOR",
							((nvr_binary ~= nil and nvr_binary) or "") .. " --remote-tab-wait +'set bufhidden=wipe'"
						)
						vim.fn.setenv(
							"EDITOR",
							((nvr_binary ~= nil and nvr_binary) or "") .. " --remote-tab-wait +'set bufhidden=wipe'"
						)
						vim.fn.setenv(
							"VISUAL",
							((nvr_binary ~= nil and nvr_binary) or "") .. " --remote-tab-wait +'set bufhidden=wipe'"
						)
					end
				end,
			})
		end,
	},
}
