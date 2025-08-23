-- External integrations
return {
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

