-- Main plugin loader - imports all plugin categories
-- This file now serves as the main entry point for all plugins

-- Import all plugin categories
return {
	-- Core plugins
	require("plugins.colorscheme"),
	require("plugins.treesitter"),

	-- LSP and completion
	require("plugins.lsp"),

	-- Editor enhancements
	require("plugins.editor"),

	-- UI improvements
	require("plugins.ui"),

	-- Code formatting
	require("plugins.formatting"),

	-- External integrations
	require("plugins.integrations"),
}

