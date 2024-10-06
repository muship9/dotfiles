-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
    -- change trouble config
    {
        "folke/trouble.nvim",
        -- opts will be merged with the parent spec
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
            -- add a keymap to browse plugin files
            -- stylua: ignore
            {
                "<leader>fp",
                function()
                    require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
                end,
                desc = "Find Plugin File",
            },
        },
        -- change some options
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
            },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_hidden = false,
                },
            },
            ensure_installed = { "go", "gomod", "gowork", "gosum" }
        },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "jose-elias-alvarez/typescript.nvim", -- TypeScript用の依存関係
            "ray-x/go.nvim", -- Go用の依存関係
            init = function()
                require("lazyvim.util").lsp.on_attach(function(_, buffer)
                    -- TypeScript関連のキーマップ
                    vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
                    vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
                end)
            end,
        },
        opts = {
            servers = {
                tsserver = {
                    enabled = false,
                },
                vtsls = {
                    filetypes = {
                        "javascript",
                        "javascriptreact",
                        "javascript.jsx",
                        "typescript",
                        "typescriptreact",
                        "typescript.tsx",
                    },
                    settings = {
                        complete_function_calls = true,
                        vtsls = {
                            enableMoveToFileCodeAction = true,
                            autoUseWorkspaceTsdk = true,
                            experimental = {
                                completion = {
                                    enableServerSideFuzzyMatch = true,
                                },
                            },
                        },
                        typescript = {
                            updateImportsOnFileMove = { enabled = "always" },
                            suggest = {
                                completeFunctionCalls = true,
                            },
                            inlayHints = {
                                enumMemberValues = { enabled = true },
                                functionLikeReturnTypes = { enabled = true },
                                parameterNames = { enabled = "literals" },
                                parameterTypes = { enabled = true },
                                propertyDeclarationTypes = { enabled = true },
                                variableTypes = { enabled = false },
                            },
                        },
                    },
                    keys = {
                        {
                            "gD",
                            function()
                                local params = vim.lsp.util.make_position_params()
                                LazyVim.lsp.execute({
                                    command = "typescript.goToSourceDefinition",
                                    arguments = { params.textDocument.uri, params.position },
                                    open = true,
                                })
                            end,
                            desc = "Goto Source Definition",
                        },
                        {
                            "gR",
                            function()
                                LazyVim.lsp.execute({
                                    command = "typescript.findAllFileReferences",
                                    arguments = { vim.uri_from_bufnr(0) },
                                    open = true,
                                })
                            end,
                            desc = "File References",
                        },
                        {
                            "<leader>co",
                            LazyVim.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                        {
                            "<leader>cM",
                            LazyVim.lsp.action["source.addMissingImports.ts"],
                            desc = "Add missing imports",
                        },
                        {
                            "<leader>cu",
                            LazyVim.lsp.action["source.removeUnused.ts"],
                            desc = "Remove unused imports",
                        },
                        {
                            "<leader>cD",
                            LazyVim.lsp.action["source.fixAll.ts"],
                            desc = "Fix all diagnostics",
                        },
                        {
                            "<leader>cV",
                            function()
                                LazyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
                            end,
                            desc = "Select TS workspace version",
                        },
                    },
                },
                gopls = {
                    gofumpt = true,
                    codelenses = {
                        gc_details = false,
                        generate = true,
                        regenerate_cgo = true,
                        run_govulncheck = true,
                        test = true,
                        tidy = true,
                        upgrade_dependency = true,
                        vendor = true,
                    },
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                    analyses = {
                        fieldalignment = true,
                        nilness = true,
                        unusedparams = true,
                        unusedwrite = true,
                        useany = true,
                    },
                    usePlaceholders = true,
                    completeUnimported = true,
                    staticcheck = true,
                    directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                    semanticTokens = true,
                },
            },
            setup = {
                tsserver = function()
                    return true
                end,
                vtsls = function(_, opts)
                    LazyVim.lsp.on_attach(function(client, buffer)
                        client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
                            local action, uri, range = unpack(command.arguments)

                            local function move(newf)
                                client.request("workspace/executeCommand", {
                                    command = command.command,
                                    arguments = { action, uri, range, newf },
                                })
                            end

                            local fname = vim.uri_to_fname(uri)
                            client.request("workspace/executeCommand", {
                                command = "typescript.tsserverRequest",
                                arguments = {
                                    "getMoveToRefactoringFileSuggestions",
                                    {
                                        file = fname,
                                        startLine = range.start.line + 1,
                                        startOffset = range.start.character + 1,
                                        endLine = range["end"].line + 1,
                                        endOffset = range["end"].character + 1,
                                    },
                                },
                            }, function(_, result)
                                ---@type string[]
                                local files = result.body.files
                                table.insert(files, 1, "Enter new path...")
                                vim.ui.select(files, {
                                    prompt = "Select move destination:",
                                    format_item = function(f)
                                        return vim.fn.fnamemodify(f, ":~:.")
                                    end,
                                }, function(f)
                                    if f and f:find("^Enter new path") then
                                        vim.ui.input({
                                            prompt = "Enter move destination:",
                                            default = vim.fn.fnamemodify(fname, ":h") .. "/",
                                            completion = "file",
                                        }, function(newf)
                                            return newf and move(newf)
                                        end)
                                    elseif f then
                                        move(f)
                                    end
                                end)
                            end)
                        end
                    end, "vtsls")
                    -- copy typescript settings to javascript
                    opts.settings.javascript = vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
                end,
            },
            -- goplsのセットアップ
            gopls = function(_, opts)
                -- workaround for gopls not supporting semanticTokensProvider
                -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
                LazyVim.lsp.on_attach(function(client, _)
                    if not client.server_capabilities.semanticTokensProvider then
                        local semantic = client.config.capabilities.textDocument.semanticTokens
                        client.server_capabilities.semanticTokensProvider = {
                            full = true,
                            legend = {
                                tokenTypes = semantic.tokenTypes,
                                tokenModifiers = semantic.tokenModifiers,
                            },
                            range = true,
                        }
                    end
                end, "gopls")
                -- end workaround
            end,
        },
    },
},

-- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
-- treesitter, mason and typescript.nvim. So instead of the above, you can use:
{ import = "lazyvim.plugins.extras.lang.typescript" },

-- add more treesitter parsers
{
    "nvim-treesitter/nvim-treesitter",
    opts = {
        ensure_installed = {
            "bash",
            "html",
            "javascript",
            "json",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "regex",
            "tsx",
            "typescript",
            "vim",
            "yaml",
            "go",
            "ruby"
        },
    },
},

-- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
-- would overwrite `ensure_installed` with the new value.
-- If you'd rather extend the default config, use the code below instead:
{
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
        -- add tsx and treesitter
        vim.list_extend(opts.ensure_installed, {
            "tsx",
            "typescript",
        })
    end,
},

-- the opts function can also be used to change the default opts:
{
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
        table.insert(opts.sections.lualine_x, "😄")
    end,
},

-- or you can return new options to override all the defaults
{
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
        return {
            --[[add your custom lualine config here]]
        }
    end,
},

-- use mini.starter instead of alpha
{ import = "lazyvim.plugins.extras.ui.mini-starter" },

-- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
{ import = "lazyvim.plugins.extras.lang.json" },

-- add any tools you want to have installed below
{
    "williamboman/mason.nvim",
    opts = {
        ensure_installed = {
            "stylua",
            "shellcheck",
            "shfmt",
            "flake8",
        }
      }
    }
  }
}
