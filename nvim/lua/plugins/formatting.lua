-- ~/.config/nvim/lua/plugins/formatting.lua
return {
    -- null-lsを使ってPrettierを設定
    {
        "jose-elias-alvarez/null-ls.nvim",
        opts = function(_, opts)
            local null_ls = require("null-ls")
            -- Prettierを追加
            table.insert(opts.sources, null_ls.builtins.formatting.prettier)
        end,
    },

    -- 保存時に自動フォーマットを実行
    {
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json" },
            callback = function()
                vim.lsp.buf.format()
            end,
        }),
    },
}

