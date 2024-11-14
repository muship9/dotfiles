return {
    -- change trouble config
    {
        "folke/trouble.nvim",
        opts = { use_diagnostic_signs = true },
    },

    -- disable trouble
    { "folke/trouble.nvim", enabled = false },

    -- override nvim-cmp and add cmp-emoji
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-emoji" },
        opts = function(_, opts)
            table.insert(opts.sources, { name = "emoji" })
        end,
    },

    -- change some telescope options and a keymap to browse plugin files
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            {
                "<leader>fp",
                function()
                    require("telescope.builtin").find_files({
                        cwd = require("lazy.core.config").options.root,
                        hidden = false,
                    })
                end,
                desc = "Find Plugin File",
            },
        },
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
            },
        },
    },

    -- Neo-tree configuration
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_gitignored = true,
                    hide_hidden = false,
                },
            },
            ensure_installed = { "go", "gomod", "gowork", "gosum" },
        },
    },

    -- LSP configurations for TypeScript and Go
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "jose-elias-alvarez/typescript.nvim",
            "ray-x/go.nvim",
            init = function()
                require("lazyvim.util").lsp.on_attach(function(_, buffer)
                    vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
                    vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
                end)
            end,
        },
        opts = {
            servers = {
                tsserver = { enabled = false },
                vtsls = {
                    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                    settings = {
                        complete_function_calls = true,
                        vtsls = {
                            enableMoveToFileCodeAction = true,
                            autoUseWorkspaceTsdk = true,
                            experimental = { completion = { enableServerSideFuzzyMatch = true } },
                        },
                        typescript = {
                            updateImportsOnFileMove = { enabled = "always" },
                            suggest = { completeFunctionCalls = true },
                            inlayHints = {
                                enumMemberValues = { enabled = true },
                                functionLikeReturnTypes = { enabled = true },
                                parameterNames = { enabled = "literals" },
                                parameterTypes = { enabled = true },
                            },
                        },
                    },
                },
                gopls = {
                    gofumpt = true,
                    analyses = { fieldalignment = true, nilness = true },
                    staticcheck = true,
                },
            },
        },
    },

    -- Treesitter configuration with additional parsers
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "bash", "html", "javascript", "json", "lua", "markdown",
                "python", "query", "regex", "tsx", "typescript", "vim", "yaml", "go", "ruby"
            },
        },
    },

    -- lualine with custom configuration
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            table.insert(opts.sections.lualine_x, "😄")
        end,
    },

    -- use mini.starter instead of alpha
    { import = "lazyvim.plugins.extras.ui.mini-starter" },

    -- add jsonls and schemastore packages
    { import = "lazyvim.plugins.extras.lang.json" },

    -- tools to install with mason
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua", "shellcheck", "shfmt", "flake8",
            }
        },
    },
}

