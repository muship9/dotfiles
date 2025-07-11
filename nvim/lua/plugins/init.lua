-- Minimal plugin configuration
return {
	-- Colorscheme
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme kanagawa]])
		end,
	},

	-- Treesitter for syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"javascript",
					"typescript",
					"tsx",
					"json",
					"html",
					"css",
					"python",
					"rust",
					"go",
					"markdown",
					"markdown_inline",
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
			})
		end,
	},

	-- Mason (LSP installer) - バイナリインストールのみ
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	-- Mason-lspconfig bridge
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls",
					"gopls",
					"rust_analyzer",
					"pyright",
					"lua_ls",
				},
				automatic_installation = true,
			})
		end,
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- 既存の設定をそのまま維持...
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")

			-- Setup capabilities for nvim-cmp
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if has_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			-- プロジェクトルートを検出するヘルパー関数
			local function get_project_root(pattern)
				return function(fname)
					return util.root_pattern(pattern)(fname) or util.find_git_ancestor(fname) or vim.fn.getcwd()
				end
			end

			-- TypeScript/JavaScript
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				root_dir = get_project_root({ "package.json", "tsconfig.json", "jsconfig.json", ".git" }),
				single_file_support = true,
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
			})

			-- Go
			lspconfig.gopls.setup({
				capabilities = capabilities,
				root_dir = get_project_root({ "go.mod", ".git" }),
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
						},
						staticcheck = true,
						gofumpt = true,
					},
				},
			})

			-- Rust
			lspconfig.rust_analyzer.setup({
				capabilities = capabilities,
				root_dir = get_project_root({ "Cargo.toml", ".git" }),
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
						},
						procMacro = {
							enable = true,
						},
					},
				},
			})

			-- Python
			lspconfig.pyright.setup({
				capabilities = capabilities,
				root_dir = get_project_root({ "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt", ".git" }),
			})

			-- Lua
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				root_dir = get_project_root({
					".luarc.json",
					".luarc.jsonc",
					".luacheckrc",
					".stylua.toml",
					"stylua.toml",
					"selene.toml",
					"selene.yml",
					".git",
				}),
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			-- Keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Buffer local mappings
					local opts = { buffer = ev.buf, noremap = true, silent = true }
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- LSP attached silently
					-- FzfLuaを使用したLSPキーマップ
					vim.keymap.set(
						"n",
						"gd",
						"<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>",
						opts
					)
					vim.keymap.set(
						"n",
						"gr",
						"<cmd>FzfLua lsp_references jump_to_single_result=true ignore_current_line=true<cr>",
						opts
					)
					vim.keymap.set(
						"n",
						"gi",
						"<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>",
						opts
					)
					vim.keymap.set(
						"n",
						"gy",
						"<cmd>FzfLua lsp_typedefs jump_to_single_result=true ignore_current_line=true<cr>",
						opts
					)

					-- 通常のLSPキーマップ
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

					-- Additional useful mappings with telescope
					vim.keymap.set("n", "<leader>ds", function()
						require("telescope.builtin").lsp_document_symbols()
					end, opts)
					vim.keymap.set("n", "<leader>ws", function()
						require("telescope.builtin").lsp_dynamic_workspace_symbols()
					end, opts)
					vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
					vim.keymap.set("n", "<leader>q", function()
						require("telescope.builtin").diagnostics()
					end, opts)

					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
				end,
			})

			-- Show line diagnostics automatically in hover window
			vim.o.updatetime = 250
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					local opts = {
						focusable = false,
						close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
						border = "rounded",
						source = "always",
						prefix = " ",
						scope = "cursor",
					}
					vim.diagnostic.open_float(nil, opts)
				end,
			})

			-- Create a command to show LSP info
			vim.api.nvim_create_user_command("LspInfo", function()
				local clients = vim.lsp.get_clients()
				if #clients == 0 then
					print("No active LSP clients")
				else
					for _, client in ipairs(clients) do
						print(string.format("LSP: %s (id: %d)", client.name, client.id))
					end
				end
			end, {})

			-- Create a command to show current filetype and debug info
			vim.api.nvim_create_user_command("LspDebug", function()
				local buf = vim.api.nvim_get_current_buf()
				local ft = vim.bo[buf].filetype
				print("Current filetype: " .. ft)
				print("Current buffer: " .. buf)
				local clients = vim.lsp.get_clients({ bufnr = buf })
				if #clients == 0 then
					print("No LSP clients attached to this buffer")
				else
					for _, client in ipairs(clients) do
						print(string.format("Attached LSP: %s (id: %d)", client.name, client.id))
					end
				end
			end, {})

			-- Create a command to manually start LSP
			vim.api.nvim_create_user_command("LspStart", function()
				local buf = vim.api.nvim_get_current_buf()
				local ft = vim.bo[buf].filetype
				print("Attempting to start LSP for filetype: " .. ft)

				-- 汎用的なLSPコマンド検索関数
				local function find_cmd(server_name, alternatives)
					-- Mason から探す
					local mason_path = vim.fn.stdpath("data") .. "/mason/bin/" .. server_name
					if vim.fn.executable(mason_path) == 1 then
						return { mason_path }
					end

					-- 代替パスから探す
					if alternatives then
						for _, alt in ipairs(alternatives) do
							if vim.fn.executable(alt) == 1 then
								return { alt }
							end
						end
					end

					-- システムパスから探す
					if vim.fn.executable(server_name) == 1 then
						return { server_name }
					end

					return nil
				end

				if ft == "typescript" or ft == "javascript" or ft == "typescriptreact" or ft == "javascriptreact" then
					local cmd = find_cmd("typescript-language-server", {
						"tsserver",
						vim.fn.expand("~/.volta/bin/typescript-language-server"),
						vim.fn.expand("~/.nvm/versions/node/*/bin/typescript-language-server"),
					})
					if cmd then
						table.insert(cmd, "--stdio")
						vim.lsp.start({
							name = "ts_ls",
							cmd = cmd,
							root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(
								vim.fn.expand("%:p:h")
							) or vim.fn.getcwd(),
							single_file_support = true,
						})
					else
						print("TypeScript language server not found. Please install it via Mason or npm.")
					end
				elseif ft == "go" then
					local cmd = find_cmd("gopls")
					if cmd then
						vim.lsp.start({
							name = "gopls",
							cmd = cmd,
							root_dir = util.root_pattern("go.mod", ".git")(vim.fn.expand("%:p:h")) or vim.fn.getcwd(),
						})
					else
						print("gopls not found. Please install it via Mason or go install.")
					end
				elseif ft == "rust" then
					local cmd = find_cmd("rust-analyzer")
					if cmd then
						vim.lsp.start({
							name = "rust_analyzer",
							cmd = cmd,
							root_dir = util.root_pattern("Cargo.toml", ".git")(vim.fn.expand("%:p:h"))
								or vim.fn.getcwd(),
						})
					else
						print("rust-analyzer not found. Please install it via Mason or rustup.")
					end
				elseif ft == "python" then
					local cmd = find_cmd("pyright-langserver", { "pyright" })
					if cmd then
						table.insert(cmd, "--stdio")
						vim.lsp.start({
							name = "pyright",
							cmd = cmd,
							root_dir = util.root_pattern(
								"setup.py",
								"setup.cfg",
								"pyproject.toml",
								"requirements.txt",
								".git"
							)(vim.fn.expand("%:p:h")) or vim.fn.getcwd(),
						})
					else
						print("pyright not found. Please install it via Mason or npm.")
					end
				elseif ft == "lua" then
					local cmd = find_cmd("lua-language-server")
					if cmd then
						vim.lsp.start({
							name = "lua_ls",
							cmd = cmd,
							root_dir = util.root_pattern(
								".luarc.json",
								".luarc.jsonc",
								".luacheckrc",
								".stylua.toml",
								"stylua.toml",
								"selene.toml",
								"selene.yml",
								".git"
							)(vim.fn.expand("%:p:h")) or vim.fn.getcwd(),
						})
					else
						print("lua-language-server not found. Please install it via Mason.")
					end
				else
					print("No LSP configured for filetype: " .. ft)
				end
			end, {})
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

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

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					lua = { "stylua" },
					python = { "black" },
					rust = { "rustfmt" },
					go = { "gofumpt" },
				},
				format_on_save = function(bufnr)
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_fallback = true }
				end,
			})
		end,
	},

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = "|",
					section_separators = "",
					globalstatus = true, -- Single statusline for all windows
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{
							"filename",
							file_status = true, -- Displays file status (readonly status, modified status)
							newfile_status = false, -- Display new file status (new file means no write after created)
							path = 1, -- 0: Just the filename
							-- 1: Relative path
							-- 2: Absolute path
							-- 3: Absolute path, with tilde as the home directory
							shorting_target = 40, -- Shortens path to leave 40 spaces in the window
							symbols = {
								modified = "[+]", -- Text to show when the file is modified
								readonly = "[RO]", -- Text to show when the file is non-modifiable or readonly
								unnamed = "[No Name]", -- Text to show for unnamed buffers
								newfile = "[New]", -- Text to show for newly created file before first write
							},
						},
					},
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- Buffer tabs
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					themable = true,
					numbers = "none",
					close_command = "bdelete! %d",
					right_mouse_command = "bdelete! %d",
					left_mouse_command = "buffer %d",
					middle_mouse_command = nil,
					indicator = {
						icon = "▎",
						style = "icon",
					},
					buffer_close_icon = "",
					modified_icon = "●",
					close_icon = "",
					left_trunc_marker = "",
					right_trunc_marker = "",
					max_name_length = 30,
					max_prefix_length = 30,
					truncate_names = true,
					tab_size = 21,
					diagnostics = "nvim_lsp",
					diagnostics_update_in_insert = false,
					color_icons = true,
					show_buffer_icons = true,
					show_buffer_close_icons = true,
					show_close_icon = true,
					show_tab_indicators = true,
					show_duplicate_prefix = true,
					persist_buffer_sort = true,
					separator_style = "slant",
					enforce_regular_tabs = false,
					always_show_bufferline = true,
					hover = {
						enabled = true,
						delay = 200,
						reveal = { "close" },
					},
					sort_by = "insert_after_current",
				},
			})
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
	-- Claude integration (optional)
	{
		"greggh/claude-code.nvim",
		cmd = "ClaudeCode",
		keys = {
			{ "<leader>cd", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
		},
		config = function()
			require("claude-code").setup({
				window = {
					position = "float",
					float = {
						width = "90%", -- Take up 90% of the editor width
						height = "90%", -- Take up 90% of the editor height
						row = "center", -- Center vertically
						col = "center", -- Center horizontally
						relative = "editor",
						border = "double", -- Use double border style
					},
				},
			})
		end,
	},
}
