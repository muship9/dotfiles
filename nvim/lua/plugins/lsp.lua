-- LSP Configuration
-- tj
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
			local mlsp = require("mason-lspconfig")
			mlsp.setup({
				ensure_installed = {
					"gopls",
					"rust_analyzer",
					"pyright",
					"lua_ls",
					"marksman", -- Markdown LSP
				},
			})

			-- 自動セットアップ時に ts_ls / vtsls をスキップ（競合回避）
			if type(mlsp.setup_handlers) == "function" then
				mlsp.setup_handlers({
					function(server)
						-- 既にこのファイルで個別設定している/不要なものはスキップ
						local skip = {
							gopls = true,
							rust_analyzer = true,
							pyright = true,
							lua_ls = true,
							marksman = true,
							-- TypeScript 系は typescript-tools を優先
							vtsls = true,
							ts_ls = true,
							tsserver = true,
						}
						if skip[server] then return end

						-- vim.lsp.config を使用 (Neovim 0.11+)
						if vim.lsp.config and vim.lsp.config[server] then
							vim.lsp.enable(server)
						end
					end,
				})
			end
			end,
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- lspconfig.util は引き続き使用可能
			local util = require("lspconfig.util")

			-- Setup capabilities for nvim-cmp
			-- 念のため、vtsls/ts_ls のデフォルト自動起動を抑止
			pcall(function()
				if vim.lsp.config.vtsls then
					vim.lsp.config.vtsls = vim.tbl_extend("force", vim.lsp.config.vtsls, { autostart = false })
				end
				if vim.lsp.config.ts_ls then
					vim.lsp.config.ts_ls = vim.tbl_extend("force", vim.lsp.config.ts_ls, { autostart = false })
				end
			end)
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

			-- Go
			vim.lsp.config.gopls = {
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
			}
			vim.lsp.enable('gopls')

			-- Rust
			vim.lsp.config.rust_analyzer = {
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
			}
			vim.lsp.enable('rust_analyzer')

			-- Python
			vim.lsp.config.pyright = {
				capabilities = capabilities,
				root_dir = get_project_root({ "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt", ".git" }),
			}
			vim.lsp.enable('pyright')

			-- Lua
			vim.lsp.config.lua_ls = {
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
			}
			vim.lsp.enable('lua_ls')

			-- Markdown
			vim.lsp.config.marksman = {
				capabilities = capabilities,
				root_dir = get_project_root({ ".git", ".marksman.toml" }),
				filetypes = { "markdown", "markdown.mdx" },
			}
			vim.lsp.enable('marksman')

			-- Keymaps
			-- 競合デタッチ関数（TS/JS バッファ用）
			-- 注意: typescript-tools.nvim のクライアント名は多くの環境で "tsserver" になる。
			-- ここで "tsserver" を止めると本命の LSP を自殺させるため、除外する。
			local function ts_detach_conflicts(bufnr)
				for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
					if vim.tbl_contains({ "ts_ls", "vtsls" }, c.name) then
						if vim.lsp.buf_is_attached(bufnr, c.id) then
							pcall(vim.lsp.buf_detach_client, bufnr, c.id)
						end
						pcall(vim.lsp.stop_client, c.id, true)
						vim.notify(string.format("Stopped conflicting TS LSP: %s", c.name), vim.log.levels.DEBUG)
					end
				end
			end

			-- 手動クリーニング用コマンド
			vim.api.nvim_create_user_command("TSDetachConflicts", function()
				local b = vim.api.nvim_get_current_buf()
				ts_detach_conflicts(b)
			end, { desc = "Detach ts_ls/vtsls from current buffer" })

			-- TypeScript Tools を安全に再起動するユーティリティ
			-- lspconfig の :LspRestart は typescript-tools には使えないため自前実装
			vim.api.nvim_create_user_command("TSRestart", function()
				local buf = vim.api.nvim_get_current_buf()
				-- ts_tools の可能性があるクライアント名を対象に停止
				for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
					if vim.tbl_contains({ "tsserver", "typescript-tools" }, c.name) then
						pcall(vim.lsp.stop_client, c.id, true)
						vim.notify(string.format("Restarting TypeScript LSP (stopped %s)", c.name), vim.log.levels.INFO)
					end
				end
				-- 再アタッチを促す
				vim.defer_fn(function()
					if vim.api.nvim_buf_is_valid(buf) then
						pcall(vim.cmd, "edit")
					end
				end, 50)
			end, { desc = "Restart TypeScript LSP from current buffer" })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Buffer local mappings
					local opts = { buffer = ev.buf, noremap = true, silent = true }
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- 診断を強制有効化し、インライン表示（virtual_text）を再設定
					pcall(vim.diagnostic.enable, { bufnr = ev.buf })
					pcall(vim.diagnostic.config, {
						virtual_text = {
							prefix = "●",
							spacing = 2,
							severity = nil,
							source = "if_many",
						},
					signs = { severity = nil },
					underline = { severity = nil },
					severity_sort = true,
				})
					vim.keymap.set(
						"n",
						"gd",
						vim.lsp.buf.definition,
						opts
					)

					-- TypeScript 周りの LSP 競合を回避（typescript-tools を優先）
					local ft = vim.bo[ev.buf].filetype
					local is_ts = vim.tbl_contains({ "typescript", "typescriptreact", "javascript", "javascriptreact" }, ft)
					if is_ts then
						-- いま attach したクライアントに関係なく全体をスキャンして除去
						vim.defer_fn(function() ts_detach_conflicts(ev.buf) end, 50)
					end

					-- LSP attached silently
					-- FzfLuaを使用したLSPキーマップ
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
					vim.keymap.set("n", "gy", "<cmd>FzfLua lsp_typedefs jump_to_single_result=true ignore_current_line=true<cr>", opts)

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

			-- グローバル診断設定（TypeScript以外のファイル用）
			-- TypeScript/JavaScriptファイルの診断設定はautocmds.luaで管理される
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					spacing = 4,
					severity = nil, -- すべてのレベルを表示
				},
				signs = {
					severity = nil, -- すべてのレベルを表示
				},
				update_in_insert = false,
				underline = {
					severity = nil, -- すべてのレベルを表示
				},
				severity_sort = true,
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

			-- LSPハンドラーの最適化
			local orig_hover = vim.lsp.handlers["textDocument/hover"]
			vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
				if result and result.contents then
					-- hover内容を制限
					if type(result.contents) == "string" and #result.contents > 5000 then
						result.contents = string.sub(result.contents, 1, 5000) .. "\n\n... (truncated)"
					elseif type(result.contents) == "table" and result.contents.value and #result.contents.value > 5000 then
						result.contents.value = string.sub(result.contents.value, 1, 5000) .. "\n\n... (truncated)"
					end
				end
				orig_hover(err, result, ctx, config)
			end

			-- signature helpの最適化
			local orig_signature = vim.lsp.handlers["textDocument/signatureHelp"]
			vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
				if result and result.signatures then
					-- signature数を制限
					if #result.signatures > 3 then
						result.signatures = {result.signatures[1], result.signatures[2], result.signatures[3]}
					end
				end
				orig_signature(err, result, ctx, config)
			end

			-- 大規模ファイル用のタイムアウト調整
			vim.api.nvim_create_autocmd("BufReadPost", {
				callback = function(args)
					local size = vim.fn.getfsize(args.file)
					if size > 1024 * 1024 then -- 1MB以上
						-- タイムアウトを延長
						vim.bo[args.buf].updatetime = 500
					end
				end,
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

			-- Optional LSP detach logging (enable with DOTFILES_LSP_DEBUG=1)
			if vim.env.DOTFILES_LSP_DEBUG == "1" then
				vim.api.nvim_create_autocmd("LspDetach", {
					group = vim.api.nvim_create_augroup("UserLspDebugDetach", { clear = true }),
					callback = function(ev)
						local client = vim.lsp.get_client_by_id(ev.data.client_id)
						if client then
							vim.notify(string.format("LSP detached: %s (buf=%d)", client.name, ev.buf), vim.log.levels.DEBUG)
						end
					end,
				})
			end

			-- Create a command to show current filetype and debug info
			vim.api.nvim_create_user_command("LspDebug", function()
				local buf = vim.api.nvim_get_current_buf()
				local ft = vim.bo[buf].filetype
				print("Current filetype: " .. ft)
				print("Current buffer: " .. buf)
				print("Large file: " .. tostring(vim.b[buf].large_file or false))
					-- Neovim 0.11+: is_enabled は filter テーブルを受け取る
					print("Diagnostics enabled: " .. tostring(vim.diagnostic.is_enabled({ bufnr = buf })))
				
				local clients = vim.lsp.get_clients({ bufnr = buf })
				if #clients == 0 then
					print("No LSP clients attached to this buffer")
				else
					for _, client in ipairs(clients) do
						print(string.format("Attached LSP: %s (id: %d)", client.name, client.id))
					end
				end
				
				-- 診断情報をチェック
				local diagnostics = vim.diagnostic.get(buf)
				print(string.format("Diagnostics count: %d", #diagnostics))
				if #diagnostics > 0 then
					print("Sample diagnostic:")
					local diag = diagnostics[1]
					print(string.format("  Line: %d, Severity: %d, Source: %s, Message: %s", 
						diag.lnum + 1, diag.severity, diag.source or "unknown", diag.message))
				end
			end, {})
			
			-- 診断を強制的に表示するコマンド
			vim.api.nvim_create_user_command("DiagnosticShow", function()
				local buf = vim.api.nvim_get_current_buf()
				vim.diagnostic.show(nil, buf)
				vim.notify("診断を強制表示しました", vim.log.levels.INFO)
			end, {})

			-- LSPクライアントの全体的な設定
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
				vim.lsp.handlers.hover, {
					border = "none",
					max_width = 80,
				}
			)
			
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
				vim.lsp.handlers.signature_help, {
					border = "none",
					max_width = 80,
				}
			)
			
			-- 大規模ファイル用のLSP設定
			local orig_buf_request = vim.lsp.buf_request
			vim.lsp.buf_request = function(bufnr, method, params, handler)
				local timeout = 5000 -- 5秒のタイムアウト
				
				-- ファイルサイズをチェック
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				if ok and stats and stats.size > 1000000 then -- 1MB以上のファイル
					timeout = 10000 -- 10秒に延長
				end
				
				return orig_buf_request(bufnr, method, params, handler)
			end

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

				if ft == "go" then
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

	-- TypeScript Tools - Alternative to typescript-language-server
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		config = function()
			-- 起動前チェック: Node/TypeScript の検出とわかりやすい通知
			local has_lspconfig, util = pcall(require, "lspconfig.util")
			if not has_lspconfig then
				util = vim.lsp.util -- フォールバック
			end
			local function find_tsserver_lib(startpath)
				local root = util.root_pattern("package.json", "tsconfig.json", ".git")(startpath)
				or vim.fn.getcwd()

				-- プロジェクトローカル優先
				local local_lib = root .. "/node_modules/typescript/lib/tsserverlibrary.js"
				if vim.fn.filereadable(local_lib) == 1 then
					return root .. "/node_modules/typescript/lib"
				end

				-- よくあるグローバルの場所も試す（Homebrew/npm グローバル）
				local candidates = {
					vim.fn.expand("$HOME") .. "/.npm-global/lib/node_modules/typescript/lib/tsserverlibrary.js",
					"/usr/local/lib/node_modules/typescript/lib/tsserverlibrary.js",
					"/opt/homebrew/lib/node_modules/typescript/lib/tsserverlibrary.js",
				}
				for _, p in ipairs(candidates) do
					if vim.fn.filereadable(p) == 1 then
						return vim.fn.fnamemodify(p, ":h")
					end
				end

				-- VOLTA 経由のNode配下（バージョンごと）を緩く探索
				local volta = vim.fn.expand("$VOLTA_HOME")
				if volta ~= "" then
					local globbed = vim.fn.glob(volta .. "/tools/image/node/*/lib/node_modules/typescript/lib/tsserverlibrary.js", true, true)
					if #globbed > 0 then
						return vim.fn.fnamemodify(globbed[1], ":h")
					end
				end

				return nil
			end

			local has_node = vim.fn.executable("node") == 1
			local bufpath = vim.api.nvim_buf_get_name(0)
			local ts_lib = find_tsserver_lib(bufpath ~= "" and bufpath or vim.fn.getcwd())

			if not has_node then
				vim.notify("Node.js が見つからず TypeScript LSP を起動できません。\n" ..
					"ターミナルから nvim を起動するか、PATH を見直してください。\n" ..
					"例: volta/nodenv/asdf の初期化、または Homebrew の node をインストール", vim.log.levels.ERROR)
				return
			end

			if not ts_lib then
				vim.notify("TypeScript が見つからず tsserver を起動できません。\n" ..
					"プロジェクトに TypeScript を追加してください（推奨）: npm i -D typescript\n" ..
					"またはグローバル: npm i -g typescript\n" ..
					"追加の候補: /usr/local や /opt/homebrew のグローバル lib を確認", vim.log.levels.ERROR)
				-- 見つからなくても後続のインストール後で再読込すれば動くため return
				return
			end

			-- ステータス確認用コマンド
			vim.api.nvim_create_user_command("TSStatus", function()
				vim.notify(("Node: %s\nTypeScript lib: %s"):format(has_node and "OK" or "NG", ts_lib or "not found"), vim.log.levels.INFO)
			end, {})

			require("typescript-tools").setup({
				settings = {
					-- 検出した tsserver ライブラリパスを優先使用
					tsserver_path = ts_lib,
				},
				on_attach = function(client, bufnr)
					-- Disable formatting if you use prettier or another formatter
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					-- 診断設定を統一（すべてのTypeScriptファイルに適用）
					-- autocmds.luaで設定されるため、ここでは重複設定を避ける
					-- 通知のみ行う
					vim.notify(string.format("TypeScript LSP attached to buffer %d", bufnr), vim.log.levels.DEBUG)

					-- Buffer local mappings (similar to existing LSP mappings)
					local opts = { buffer = bufnr, noremap = true, silent = true }

					-- Use FzfLua for definitions and references (matching existing setup)
					vim.keymap.set(
						"n",
						"gd",
						vim.lsp.buf.definition,
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
					vim.keymap.set("n", "gy", "<cmd>FzfLua lsp_typedefs jump_to_single_result=true ignore_current_line=true<cr>", opts)

					-- Standard LSP mappings
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

					-- TypeScript specific commands
					vim.keymap.set(
						"n",
						"<leader>to",
						"<cmd>TSToolsOrganizeImports<cr>",
						{ buffer = bufnr, desc = "Organize Imports" }
					)
					vim.keymap.set(
						"n",
						"<leader>ts",
						"<cmd>TSToolsSortImports<cr>",
						{ buffer = bufnr, desc = "Sort Imports" }
					)
					vim.keymap.set(
						"n",
						"<leader>tr",
						"<cmd>TSToolsRemoveUnusedImports<cr>",
						{ buffer = bufnr, desc = "Remove Unused Imports" }
					)
					vim.keymap.set("n", "<leader>tf", "<cmd>TSToolsFixAll<cr>", { buffer = bufnr, desc = "Fix All" })

					-- Diagnostic mappings
					vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

					-- Enable completion triggered by <c-x><c-o>
					vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
				end,
				settings = vim.tbl_deep_extend("force", {
					-- メモリ制限設定 (8GB - 大規模プロジェクト対応)
					tsserver_max_memory = 8192,
					
					-- 診断用に別のtsserverインスタンスを使用（メモリ圧迫を軽減）
					separate_diagnostic_server = true,
					
					-- tsserver settings
					tsserver_file_preferences = {
						includeInlayParameterNameHints = "all",
						includeCompletionsForModuleExports = true,
						quotePreference = "auto",
						-- 大規模ファイル用のパフォーマンス設定
						disableSuggestions = false,
						useLabelDetailsInCompletionEntries = true,
						-- 補完のタイムアウトを延長
						includeCompletionsWithInsertText = true,
						includeCompletionsWithSnippetText = true,
						includeAutomaticOptionalChainCompletions = true,
					},
					tsserver_format_options = {
						allowIncompleteCompletions = false,
						allowRenameOfImportPath = false,
					},

					-- Code lens settings
					code_lens = "off", -- "all", "implementations_only", "references_only", "off"
					disable_member_code_lens = true,

					-- JSX close tag
					jsx_close_tag = {
						enable = true,
						filetypes = { "javascriptreact", "typescriptreact" },
					},
				}, settings or {}),
			})
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

			-- Helper: quick debug command to check cmp status
			pcall(vim.api.nvim_create_user_command, "CmpDebug", function()
				local ok, core = pcall(function()
					return require("cmp").core
				end)
				print("cmp loaded: " .. tostring(ok))
				print("cmp visible: " .. tostring(cmp.visible()))
				print("cmp enabled: " .. tostring(cmp.get_config().enabled ~= false))
				local sources = {}
				for _, s in ipairs(cmp.get_config().sources or {}) do
					table.insert(sources, s.name)
				end
				print("cmp sources: " .. table.concat(sources, ", "))
			end, {})

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
					{ 
						name = "nvim_lsp",
						-- 大規模ファイル用の最適化
						max_item_count = 50,
						priority = 1000,
					},
					{ 
						name = "luasnip",
						max_item_count = 10,
						priority = 750,
					},
				}, {
					{ 
						name = "buffer",
						max_item_count = 10,
						priority = 500,
						option = {
							get_bufnrs = function()
								-- 現在のバッファのみを対象にする（大規模プロジェクトでのパフォーマンス向上）
								return { vim.api.nvim_get_current_buf() }
							end,
						},
					},
					{ 
						name = "path",
						max_item_count = 10,
						priority = 250,
					},
				}),
				-- パフォーマンス設定
				performance = {
					debounce = 60,
					throttle = 30,
					fetching_timeout = 2000, -- TypeScriptの複雑な型推論に対応
					confirm_resolve_timeout = 80,
					async_budget = 1,
					max_view_entries = 50,
				},
				-- 補完ウィンドウの設定
				window = {
					completion = {
						scrollbar = false,
					},
				},
			})
		end,
	},
}
