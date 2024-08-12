# 配置したい設定ファイル
dotfiles=(~/dotfiles/.zshrc ~/dotfiles/starship/starship.toml ~/dotfiles/wezterm/ ~/dotfiles/nvim/)

# .zshrc のシンボリックリンクをホームディレクトリ直下に作成する
for file in "${dotfiles[@]}"; do
  ln -svf $file ~/
done