-- 非同期フォーマッティング設定
return {
  -- conform.nvimの非同期設定
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        rust = { "rustfmt" },
        go = { "gofumpt" },
      },
      -- 保存時の非同期フォーマット設定
      format_on_save = function(bufnr)
        -- 大規模ファイルでは無効化
        local lines = vim.api.nvim_buf_line_count(bufnr)
        if lines > 10000 then
          return
        end
        -- バッファのファイルタイプを取得
        local ft = vim.bo[bufnr].filetype
        -- 特定のファイルタイプは同期的にフォーマット（高速なフォーマッタ）
        local sync_filetypes = { "lua", "rust", "go" }
        local is_sync = vim.tbl_contains(sync_filetypes, ft)
        return {
          timeout_ms = is_sync and 2000 or 5000,
          lsp_fallback = true,
          async = not is_sync, -- 高速なフォーマッタは同期、遅いものは非同期
          quiet = false,
        }
      end,
      -- 保存後の非同期フォーマット（フォールバック）
      format_after_save = function(bufnr)
        local lines = vim.api.nvim_buf_line_count(bufnr)
        if lines > 10000 then
          return
        end

        local ft = vim.bo[bufnr].filetype
        local async_filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "json",
          "css",
          "scss",
          "html",
          "markdown",
        }

        if vim.tbl_contains(async_filetypes, ft) then
          return {
            timeout_ms = 10000, -- 非同期なので長めのタイムアウト
            lsp_fallback = true,
          }
        end
      end,
      formatters = {
        prettier = {
          prepend_args = {
            "--cache",
            "--cache-strategy",
            "content",
            "--single-quote",
            "--trailing-comma",
            "es5",
          },
        },
        stylua = {
          prepend_args = {
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
          },
        },
      },
      -- フォーマット実行時の通知
      notify_on_error = true,
      log_level = vim.log.levels.WARN,
    },
  },

  -- LSPのフォーマット設定も調整
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- フォーマット時のデフォルト設定
      vim.lsp.buf.format = function(options)
        options = options or {}
        options.timeout_ms = options.timeout_ms or 5000
        options.async = options.async ~= false -- デフォルトで非同期

        -- 元のformat関数を呼び出す
        return vim.lsp.buf.format(options)
      end

      return opts
    end,
  },
}

