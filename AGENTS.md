# Repository Guidelines
## プロジェクト構造とモジュール整理
- `nvim/` は Lua 設定 と lazy.nvim 管理 下 の プラグイン を 収め `lua/config` と `lua/plugins` で 基本 設定 と 拡張 を 分離 します。
- `zsh/` は aliases.zsh や environment.zsh など 機能 別 ファイル を 用意 し `.zshrc` から source される 想定 です。
- `starship/` `wezterm/` `git/` に ツール 別 コンフィグ を 配置 し ディレクトリ 単位 で リンク する 方針、 `ai/codex.md` は エージェント ガイド を 提供 します。
## ビルド・テスト・開発コマンド
- `./deploy.sh` は Homebrew 経由 の 補助 パッケージ 導入 と 設定 シンボリックリンク 作成 を 行う ため 更新 後 は 再実行 し 動作 を 確認 します。
- `nvim --headless "+Lazy sync" +qa` と `nvim --headless "+checkhealth" +qa` を 組み合わせ プラグイン 同期 と LSP ヘルスチェック を 自動化 できます。
- Zsh 設定 を 触れた 場合 は `zsh -n path/to/file.zsh` と `shellcheck` で 構文 を 事前 検証 し 失敗 時 は deploy を 止めます。
## コーディングスタイルと命名規約
- Lua は タブ インデント と snake_case キー を 維持 し `conform.nvim` 経由 で `stylua` を 走らせて 差分 を 整え ます。
- Bash スクリプト は `#!/usr/bin/env bash` と `set -euo pipefail` を 冒頭 に 置き `bash -n` で 文法 を チェック します。
- Zsh エイリアス 名 は `gd` `gst` など 短く 動作 を 暗示 する 形 を 継承 し 新規 追加 時 も 同じ パターン を 意識 します。
## テスト ガイドライン
- Neovim 変更 は 実際 に `nvim` を 起動 し 主要 キーマップ と 自動 コマンド を 手動 で 検証 する の が 前提 です。
- Lua 設定 を 変更 したら `:ConformFormat` と `:Mason` で 対応 フォーマッタ と LSP の 動作 を 確認 します。
- 新規 シンボリックリンク や パス 追加 は `ls -al` で 解決 先 を 目視 し 想定 通り の 設置 を 確かめ ます。
## コミット と プルリク ガイドライン
- コミット メッセージ は `type(scope): summary` 形式 で 英語 現在形 を 使い 過去 の `feat(editor)` `fix(lsp)` に そろえ ます。
- 変更 が 大きい 場合 は 機能 単位 で コミット を 切り 説明 行 に 動機 と 影響 範囲 を 記述 します。
- PR では 目的、 実行 した コマンド、 スクリーンショット など を 箇条書き で 共有 し README 手順 に 影響 する 場合 は 該当 箇所 を 同期 します。
