-- 変更部分のみをフォーマットする設定
return {
  -- LSPの範囲フォーマット設定
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- 保存時に変更された範囲のみをフォーマット
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.css", "*.scss", "*.html", "*.md" },
        callback = function(args)
          local bufnr = args.buf
          
          -- 変更された行の範囲を取得
          local hunks = vim.fn.system("git diff --no-index --no-prefix -U0 " .. vim.fn.expand("%:p") .. " -")
          
          if vim.v.shell_error == 0 and hunks ~= "" then
            -- gitで変更された範囲を解析して、その部分のみフォーマット
            local lines = vim.split(hunks, "\n")
            for _, line in ipairs(lines) do
              local start_line, count = line:match("^@@%s+%-%d+,%d+%s+%+(%d+),(%d+)%s+@@")
              if start_line and count then
                local start = tonumber(start_line)
                local end_line = start + tonumber(count) - 1
                
                -- 範囲フォーマットを実行
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  timeout_ms = 2000,
                  range = {
                    ["start"] = { start - 1, 0 },
                    ["end"] = { end_line, 0 },
                  },
                })
              end
            end
          else
            -- gitで追跡されていないファイルや、全体的な変更の場合は通常のフォーマット
            -- ただし、ファイルが大きい場合は警告
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            if line_count > 3000 then
              vim.notify("Large file detected. Consider formatting only selected ranges.", vim.log.levels.WARN)
            else
              vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
            end
          end
        end,
      })
      
      return opts
    end,
  },
  
  -- 手動で選択範囲をフォーマットするためのキーマップ
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({
            lsp_fallback = true,
            timeout_ms = 3000,
            range = {
              ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
              ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
            },
          })
        end,
        mode = { "v" },
        desc = "Format selected range",
      },
    },
  },
}