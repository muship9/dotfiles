-- LSP Configuration
return {
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
					"marksman", -- Markdown LSP
				},
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
				-- diagnosticのソース名を統一
				init_options = {
					preferences = {
						includeInlayParameterNameHints = "all",
					},
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

			-- Markdown
			lspconfig.marksman.setup({
				capabilities = capabilities,
				root_dir = get_project_root({ ".git", ".marksman.toml" }),
				filetypes = { "markdown", "markdown.mdx" },
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
						"<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>",
						opts
					)
					vim.keymap.set(
						"n",
						"gr",
						"<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>",
						opts
					)
					vim.keymap.set(
						"n",
						"gi",
						"<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>",
						opts
					)
					vim.keymap.set("n", "gy", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", opts)

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
					vim.keymap.set("n", "<leader>cd", function()
						-- まず診断情報があるか確認
						local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
						if #diagnostics == 0 then
							-- 現在行に診断情報がない場合は、バッファ全体から取得
							diagnostics = vim.diagnostic.get(0)
						end
						if #diagnostics > 0 then
							local _, winid = vim.diagnostic.open_float(nil, {
								focus = false,
								border = "none",
								header = {},
								suffix = {},
								format = function(diagnostic)
									if diagnostic.code then
										return string.format(
											"[%s](%s): %s",
											diagnostic.source,
											diagnostic.code,
											diagnostic.message
										)
									else
										return string.format("[%s]: %s", diagnostic.source, diagnostic.message)
									end
								end,
							})
							if winid then
								vim.api.nvim_set_current_win(winid)
							end
						else
							vim.notify("No diagnostics available", vim.log.levels.INFO)
						end
					end, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
					vim.keymap.set("n", "<leader>q", function()
						require("telescope.builtin").diagnostics()
					end, opts)

					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
				end,
			})

			-- 重複するdiagnosticsをフィルタリング
			local orig_handler = vim.diagnostic.handlers.virtual_text
			vim.diagnostic.handlers.virtual_text = {
				show = function(namespace, bufnr, diagnostics, opts)
					-- 重複を除去
					local filtered = {}
					local seen = {}
					for _, diag in ipairs(diagnostics) do
						local key = string.format("%d:%s", diag.lnum, diag.message)
						if not seen[key] then
							seen[key] = true
							table.insert(filtered, diag)
						end
					end
					orig_handler.show(namespace, bufnr, filtered, opts)
				end,
				hide = orig_handler.hide,
			}

			-- Diagnostic configuration
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					spacing = 4,
					-- 重複するメッセージを除外
					virt_text_hide = false,
				},
				signs = true,
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				-- 重複するdiagnosticsを処理
				virtual_text_hide_severity = nil,
				float = {
					focusable = true,
					style = "minimal",
					border = "none",
					header = {},
					suffix = {},
					format = function(diagnostic)
						if diagnostic.code then
							return string.format("[%s](%s): %s", diagnostic.source, diagnostic.code, diagnostic.message)
						else
							return string.format("[%s]: %s", diagnostic.source, diagnostic.message)
						end
					end,
				},
			})

			-- Show line diagnostics automatically in hover window
			vim.o.updatetime = 250
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					local opts = {
						focusable = false,
						close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
						border = "none",
						header = {},
						suffix = {},
						scope = "cursor",
						format = function(diagnostic)
							if diagnostic.code then
								return string.format(
									"[%s](%s): %s",
									diagnostic.source,
									diagnostic.code,
									diagnostic.message
								)
							else
								return string.format("[%s]: %s", diagnostic.source, diagnostic.message)
							end
						end,
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
				elseif ft == "markdown" then
					local cmd = find_cmd("marksman")
					if cmd then
						vim.lsp.start({
							name = "marksman",
							cmd = cmd,
							root_dir = util.root_pattern(".git", ".marksman.toml")(vim.fn.expand("%:p:h"))
								or vim.fn.getcwd(),
						})
					else
						print("marksman not found. Please install it via Mason.")
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
}
