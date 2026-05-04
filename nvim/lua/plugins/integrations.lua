-- External integrations
return {
	-- Git signs (show git diff in sign column)
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signcolumn = true,
				numhl = false,
				linehl = false,
				word_diff = false,
				watch_gitdir = {
					follow_files = true,
				},
				attach_to_untracked = true,
				current_line_blame = true,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 200,
					ignore_whitespace = false,
				},
				current_line_blame_formatter = "<author>, <author_time:%Y/%m/%d> • <summary>",
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil,
				max_file_length = 40000,
				preview_config = {
					border = "single",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Next hunk" })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Previous hunk" })

					-- Actions
					map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
					map("v", "<leader>gs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Stage hunk" })
					map("v", "<leader>gr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Reset hunk" })
					map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
					map("n", "<leader>gd", function()
						if vim.wo.diff then
							vim.cmd("diffoff! | only")
						else
							gs.diffthis()
						end
					end, { desc = "Diff this (toggle)" })
					map("n", "<leader>gD", function()
						if vim.wo.diff then
							vim.cmd("diffoff! | only")
						else
							gs.diffthis("~")
						end
					end, { desc = "Diff this ~ (toggle)" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
				end,
			})
		end,
	},

	-- Diffview (git diff viewer, works with worktrees)
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
		keys = {
			{ "<leader>dv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: 変更一覧を開く" },
			{ "<leader>dV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: 現在ファイルの履歴" },
			{ "<leader>dx", "<cmd>DiffviewClose<cr>", desc = "Diffview: 閉じる" },
		},
		config = function()
			require("diffview").setup({
				enhanced_diff_hl = true,
			})
		end,
	},

	-- Octo (GitHub issues/PRs in Neovim)
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		keys = {
			{ "<leader>pl", "<cmd>Octo pr list<cr>", desc = "GitHub PR一覧" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
			"sindrets/diffview.nvim",
		},
		opts = {
			picker = "telescope",
			enable_builtin = true,
			default_merge_method = "squash",
			mappings = {
				pull_request = {
					open_in_browser = { lhs = "<leader>gB", desc = "ブラウザでPRを開く" },
					review_start = { lhs = "<leader>rs", desc = "PRレビューを開始" },
					review_resume = { lhs = "<leader>rr", desc = "PRレビューを再開" },
					react_rocket = { lhs = "", desc = "" },
				},
				review_diff = {
					submit_review = { lhs = "<leader>re", desc = "レビューをサブミット（承認/変更要求/コメント）" },
				},
				file_panel = {
					submit_review = { lhs = "<leader>re", desc = "レビューをサブミット（承認/変更要求/コメント）" },
				},
			},
		},
	},

	-- Claude integration (optional)
	{
		"greggh/claude-code.nvim",
		cmd = "ClaudeCode",
		keys = {
			{ "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code を開く/閉じる" },
			{
				"<leader>rq",
				function()
					-- 選択範囲を取得
					local start_line = vim.fn.line("'<")
					local end_line = vim.fn.line("'>")
					local lines = vim.fn.getline(start_line, end_line)
					local selected = table.concat(lines, "\n")

					-- Octo バッファから PR 情報を取得
					local bufname = vim.api.nvim_buf_get_name(0)
					local owner, repo, pr_num = bufname:match("octo://([^/]+)/([^/]+)/pull/(%d+)")

					local context_parts = {}

					if owner and repo and pr_num then
						local pr_json = vim.fn.system(string.format(
							"gh pr view %s --repo %s/%s --json number,title,body,files 2>/dev/null",
							pr_num, owner, repo
						))
						local ok, pr = pcall(vim.fn.json_decode, pr_json)
						if ok and pr then
							table.insert(context_parts, string.format("## PR #%s: %s", pr.number, pr.title))
							if pr.body and pr.body ~= "" then
								table.insert(context_parts, string.format("### 説明\n%s", pr.body))
							end
							if pr.files and #pr.files > 0 then
								local file_names = {}
								for _, f in ipairs(pr.files) do
									table.insert(file_names, string.format("- %s", f.path))
								end
								table.insert(context_parts, "### 変更ファイル\n" .. table.concat(file_names, "\n"))
							end
						end
					end

					table.insert(context_parts, string.format("### 質問コード\n```\n%s\n```", selected))
					table.insert(context_parts, "### 質問\n")

					vim.fn.setreg("+", table.concat(context_parts, "\n\n"))
					vim.cmd("ClaudeCode")
					vim.notify("Ctrl+R+ でコンテキストをペーストしてください", vim.log.levels.INFO)
				end,
				mode = "v",
				desc = "選択コードと PR コンテキストをクリップボードにコピーして Claude に質問",
			},
		},
		config = function()
			require("claude-code").setup({
				window = {
					position = "float",
					float = {
						width = "90%",
						height = "90%",
						row = "center",
						col = "center",
						relative = "editor",
						border = "double",
					},
				},
			})
		end,
	},
}

