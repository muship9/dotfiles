# Language Environments

## 概要
各プログラミング言語の開発環境セットアップと管理方法。
Python、Node.js、Ruby、Go等のバージョン管理と環境構築。

## Python (pyenv + poetry)

### pyenvセットアップ
```bash
# インストール
brew install pyenv

# .zshrcに追加（既に設定済み）
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# 利用可能なバージョン確認
pyenv install --list

# 特定バージョンをインストール
pyenv install 3.11.7
pyenv install 3.12.0

# グローバルバージョン設定
pyenv global 3.11.7

# ローカル（プロジェクト）バージョン設定
pyenv local 3.12.0  # .python-versionファイルが作成される
```

### poetryセットアップ
```bash
# インストール
curl -sSL https://install.python-poetry.org | python3 -

# パスを通す（.zshrcに追加）
export PATH="$HOME/.local/bin:$PATH"

# 設定確認
poetry --version
```

### プロジェクトセットアップ
```bash
# 新規プロジェクト作成
poetry new my-project

# 既存プロジェクトで初期化
poetry init

# 依存関係インストール
poetry install

# パッケージ追加
poetry add requests
poetry add --dev pytest  # 開発依存関係

# 仮想環境に入る
poetry shell

# コマンド実行
poetry run python script.py
poetry run pytest
```

## Node.js (nvm)

### nvmセットアップ
```bash
# インストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# .zshrcに追加（既に設定済み）
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### Node.jsバージョン管理
```bash
# 利用可能なバージョン確認
nvm list-remote

# LTS版をインストール
nvm install --lts
nvm install 20  # 特定のメジャーバージョン
nvm install 20.11.0  # 特定バージョン

# 使用するバージョンを切り替え
nvm use 20
nvm use --lts

# デフォルトバージョン設定
nvm alias default 20

# インストール済みバージョン確認
nvm list

# プロジェクト固有の設定（.nvmrcファイル）
echo "20.11.0" > .nvmrc
nvm use  # .nvmrcを読み込む
```

### npmとパッケージ管理
```bash
# グローバルパッケージインストール
npm install -g yarn
npm install -g pnpm
npm install -g typescript

# プロジェクト初期化
npm init -y
# または
yarn init -y
# または
pnpm init

# 依存関係インストール
npm install
yarn install
pnpm install

# パッケージ追加
npm install express
yarn add express
pnpm add express
```

## Ruby (rbenv)

### rbenvセットアップ
```bash
# インストール
brew install rbenv ruby-build

# .zshrcに追加（既に設定済み）
eval "$(rbenv init - zsh)"

# インストール可能なバージョン確認
rbenv install -l

# Rubyインストール
rbenv install 3.2.2
rbenv install 3.3.0

# グローバルバージョン設定
rbenv global 3.2.2

# ローカルバージョン設定
rbenv local 3.3.0  # .ruby-versionファイルが作成される

# バージョン確認
rbenv versions
ruby --version
```

### gem管理とBundler
```bash
# Bundlerインストール
gem install bundler

# Gemfile作成
bundle init

# gem追加（Gemfileを編集後）
bundle install

# 実行
bundle exec rails server
bundle exec rspec
```

## Go

### Goセットアップ
```bash
# インストール
brew install go

# 環境変数設定（.zshrcに追加）
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# バージョン確認
go version

# ワークスペース作成
mkdir -p $GOPATH/{bin,src,pkg}
```

### Go Modules
```bash
# 新規モジュール作成
go mod init github.com/username/project

# 依存関係追加
go get github.com/gin-gonic/gin

# 依存関係の整理
go mod tidy

# ビルド
go build
go build -o myapp

# 実行
go run main.go

# テスト
go test ./...
```

## Rust (rustup)

### Rustセットアップ
```bash
# インストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# パス設定（.zshrcに追加）
source "$HOME/.cargo/env"

# バージョン確認
rustc --version
cargo --version

# ツールチェーン管理
rustup update          # 更新
rustup default stable  # 安定版を使用
rustup default nightly # ナイトリー版を使用
```

### Cargoプロジェクト
```bash
# 新規プロジェクト作成
cargo new my_project
cd my_project

# ビルド
cargo build
cargo build --release

# 実行
cargo run

# テスト
cargo test

# 依存関係追加（Cargo.tomlを編集）
# その後
cargo build  # 自動的にダウンロード
```

## 言語サーバー (LSP) 設定

### Neovim用LSPインストール
```vim
" Mason経由でインストール
:MasonInstall pyright           " Python
:MasonInstall typescript-language-server  " TypeScript/JavaScript
:MasonInstall solargraph        " Ruby
:MasonInstall gopls            " Go
:MasonInstall rust-analyzer    " Rust
:MasonInstall lua-language-server  " Lua
```

### 言語別フォーマッター
```vim
" Mason経由でインストール
:MasonInstall black            " Python
:MasonInstall prettier         " JavaScript/TypeScript/CSS/HTML
:MasonInstall rubocop          " Ruby
:MasonInstall gofmt           " Go
:MasonInstall rustfmt         " Rust
:MasonInstall stylua          " Lua
```

## プロジェクトテンプレート

### .editorconfig (全言語共通)
```ini
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.py]
indent_size = 4

[*.go]
indent_style = tab

[*.md]
trim_trailing_whitespace = false
```

### .gitignore テンプレート
```bash
# Python
__pycache__/
*.py[cod]
.venv/
.poetry/
dist/
*.egg-info/

# Node.js
node_modules/
dist/
.next/
.nuxt/
*.log

# Ruby
*.gem
.bundle/
vendor/bundle/
.ruby-version
.ruby-gemset

# Go
*.exe
*.test
*.prof
vendor/

# Rust
target/
Cargo.lock

# 共通
.DS_Store
*.swp
.env
.idea/
.vscode/
```

## トラブルシューティング

### Pythonバージョンが切り替わらない
```bash
# pyenvの再初期化
pyenv rehash

# シェルの再起動
exec $SHELL

# パスの確認
which python
pyenv which python
```

### Node.jsのバージョン自動切り替え
```bash
# .zshrcに追加（ディレクトリ移動時に自動でnvm use）
autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

### パッケージのグローバルインストール問題
```bash
# npm: プレフィックス設定
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH

# gem: --user-installを使用
gem install --user-install bundler
```