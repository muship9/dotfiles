-- LSPタイムアウト設定
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- デフォルトのLSPフォーマット設定を上書き
      local lspconfig = require("lspconfig")
      
      -- 全てのLSPサーバーに対してタイムアウトを設定
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            -- クライアントのrequest_timeoutを設定
            client.config.flags = vim.tbl_deep_extend("force", client.config.flags or {}, {
              debounce_text_changes = 150,
            })
          end
        end,
      })
      
      -- グローバルなLSP設定
      vim.lsp.handlers["textDocument/formatting"] = vim.lsp.with(
        vim.lsp.handlers["textDocument/formatting"],
        {
          timeout_ms = 2000,
        }
      )
      
      return opts
    end,
  },
}