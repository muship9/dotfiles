return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- ルートパターンを最適化（大規模リポジトリでの検索を制限）
    local util = require("lspconfig.util")
    -- 除外するディレクトリパターン
    local excluded_dirs = {
      "node_modules",
      ".git",
      "vendor",
      "build",
      "dist",
      "tmp",
      "temp",
      ".cache",
      ".next",
      ".nuxt",
      ".vuepress",
      "coverage",
      ".nyc_output",
      ".pytest_cache",
      "__pycache__",
      ".mypy_cache",
      ".tox",
      ".eggs",
      "*.egg-info",
      ".gradle",
      "target",
      ".idea",
      ".vscode",
      ".DS_Store",
    }

    -- ファイルサイズの制限（100MB）
    local max_file_size = 100 * 1024 * 1024

    -- LSPのグローバル設定
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      -- 診断の更新を遅延させる
      update_in_insert = false,
      -- 仮想テキストの表示を制限
      virtual_text = {
        spacing = 4,
        source = "if_many",
      },
    })

    -- デフォルトのcapabilitiesを調整
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

    -- 各LSPサーバーに共通の設定を適用
    local servers = opts.servers or {}
    for server_name, server_opts in pairs(servers) do
      server_opts.capabilities = vim.tbl_deep_extend("force", capabilities, server_opts.capabilities or {})

      -- root_dirの設定を最適化（新しいAPIを使用）
      server_opts.root_dir = function(fname)
        -- .gitディレクトリを探す
        local git_root = vim.fs.dirname(vim.fs.find(".git", {
          path = fname,
          upward = true,
          type = "directory",
        })[1])

        -- package.jsonを探す
        local pkg_root = vim.fs.dirname(vim.fs.find("package.json", {
          path = fname,
          upward = true,
          type = "file",
        })[1])

        -- node_modulesを探す
        local node_root = vim.fs.dirname(vim.fs.find("node_modules", {
          path = fname,
          upward = true,
          type = "directory",
        })[1])

        return git_root or pkg_root or node_root or vim.fn.getcwd()
      end

      -- 大規模ファイルではLSPを無効化
      server_opts.on_new_config = function(config, root_dir)
        local original_on_attach = config.on_attach
        config.on_attach = function(client, bufnr)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local stat = vim.uv.fs_stat(fname)

          if stat and stat.size > max_file_size then
            vim.notify("LSP disabled for large file: " .. fname, vim.log.levels.WARN)
            vim.lsp.stop_client(client.id)
            return
          end

          if original_on_attach then
            original_on_attach(client, bufnr)
          end
        end
      end

      -- ワークスペース設定
      server_opts.settings = vim.tbl_deep_extend("force", server_opts.settings or {}, {
        -- 除外パターンの設定（サーバーがサポートしている場合）
        ["workspace.library.exclude"] = excluded_dirs,
        ["files.exclude"] = vim.tbl_extend(
          "force",
          server_opts.settings and server_opts.settings["files.exclude"] or {},
          {
            ["**/node_modules"] = true,
            ["**/.git"] = true,
            ["**/vendor"] = true,
            ["**/build"] = true,
            ["**/dist"] = true,
            ["**/tmp"] = true,
            ["**/temp"] = true,
            ["**/.cache"] = true,
            ["**/.next"] = true,
            ["**/.nuxt"] = true,
            ["**/coverage"] = true,
          }
        ),
        ["files.watcherExclude"] = vim.tbl_extend(
          "force",
          server_opts.settings and server_opts.settings["files.watcherExclude"] or {},
          {
            ["**/node_modules/**"] = true,
            ["**/.git/**"] = true,
            ["**/vendor/**"] = true,
            ["**/build/**"] = true,
            ["**/dist/**"] = true,
            ["**/tmp/**"] = true,
            ["**/temp/**"] = true,
            ["**/.cache/**"] = true,
            ["**/.next/**"] = true,
            ["**/.nuxt/**"] = true,
            ["**/coverage/**"] = true,
          }
        ),
      })
    end

    return opts
  end,
}
