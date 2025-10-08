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
					map("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "Diff this ~" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
				end,
			})
		end,
	},

	-- Claude integration (optional)
	{
		"greggh/claude-code.nvim",
		cmd = "ClaudeCode",
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

	-- Obsidian integration
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			workspaces = {
				{
					name = "personal",
					path = "~/Documents/Obsidian Vault",
				},
			},
			notes_subdir = "notes",
			daily_notes = {
				folder = "daily",
				date_format = "%Y-%m-%d",
				alias_format = "%B %-d, %Y",
				default_tags = { "daily-notes" },
				template = nil,
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
			mappings = {
				["gf"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
				["<leader>ch"] = {
					action = function()
						return require("obsidian").util.toggle_checkbox()
					end,
					opts = { buffer = true },
				},
			},
			new_notes_location = "current_dir",
			preferred_link_style = "wiki",
			disable_frontmatter = false,
			-- UIの設定
			ui = {
				enable = true,
				update_debounce = 200,
				checkboxes = {
					[" "] = { char = "☐", hl_group = "ObsidianTodo" },
					["x"] = { char = "✔", hl_group = "ObsidianDone" },
				},
			},
			note_id_func = function(title)
				local suffix = ""
				if title ~= nil then
					suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
				else
					for _ = 1, 4 do
						suffix = suffix .. string.char(math.random(65, 90))
					end
				end
				return tostring(os.time()) .. "-" .. suffix
			end,
			follow_url_func = function(url)
				vim.fn.jobstart({ "open", url })
			end,
			-- デイリーノートの本文タイトルを無効化
			note_frontmatter_func = function(note)
				local out = { id = note.id, aliases = note.aliases, tags = note.tags }
				if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
					for k, v in pairs(note.metadata) do
						out[k] = v
					end
				end
				return out
			end,
		},
	},
}

