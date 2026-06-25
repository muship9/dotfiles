local wezterm = require("wezterm")

-- 各 workspace の最初のタブは cwd（= リポジトリ群の root）で開く。
-- root タブは cross-repo な実装・調査用（ここで claude を起動するなど）。
-- tabs はその配下の個別リポジトリを開く。
return {
  {
    name = "me",
    cwd = wezterm.home_dir .. "/dotfiles",
    tabs = {
      { cwd = wezterm.home_dir .. "/memo" },
      { cwd = wezterm.home_dir,           cmd = "y\n" },
    },
  },
  {
    name = "voc",
    cwd = wezterm.home_dir .. "/workspace/voc", -- root: cross-repo 用
    tabs = {
      { cwd = wezterm.home_dir .. "/workspace/voc/handy-voc" },
      { cwd = wezterm.home_dir .. "/workspace/voc/handy-voc-front" },
      { cwd = wezterm.home_dir .. "/workspace/voc/proton-voc" },
    },
  },
  {
    name = "biz-voc",
    cwd = wezterm.home_dir .. "/workspace/biz-voc", -- root: cross-repo 用
    tabs = {
      { cwd = wezterm.home_dir .. "/workspace/biz-voc/handy-biz-voc" },
      { cwd = wezterm.home_dir .. "/workspace/biz-voc/proton-biz-voc" },
      -- handy-biz-front は別 root（~/workspace/biz/）配下だが作業上ここに同居させる
      { cwd = wezterm.home_dir .. "/workspace/biz/handy-biz-front" },
    },
  },
  { name = "db",     cwd = wezterm.home_dir .. "/workspace/schema" },
  { name = "github", cwd = wezterm.home_dir .. "/workspace",       cmd = "gh dash\n" },
  {
    name = "infra",
    cwd = wezterm.home_dir .. "/workspace/infra", -- root: cross-repo 用
    tabs = {
      { cwd = wezterm.home_dir .. "/workspace/infra/terraform-resources" },
      { cwd = wezterm.home_dir .. "/workspace/infra/k8s-manifests" },
      { cwd = wezterm.home_dir .. "/workspace/infra/k8s-manifests", cmd = "k9s\n" },
    },
  },
}
