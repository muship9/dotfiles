local wezterm = require("wezterm")

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
    cwd = wezterm.home_dir .. "/workspace/voc/handy-voc",
    tabs = {
      { cwd = wezterm.home_dir .. "/workspace/voc/handy-voc-front" },
      { cwd = wezterm.home_dir .. "/workspace/voc/proton-voc" },
    },
  },
  {
    name = "biz-voc",
    cwd = wezterm.home_dir .. "/workspace/biz-voc/handy-biz-voc",
    tabs = {
      { cwd = wezterm.home_dir .. "/workspace/biz/handy-biz-front" },
      { cwd = wezterm.home_dir .. "/workspace/biz-voc/proton-biz-voc" },
    },
  },
  { name = "db",     cwd = wezterm.home_dir .. "/workspace/schema" },
  { name = "github", cwd = wezterm.home_dir .. "/workspace",       cmd = "gh dash\n" },
  {
    name = "infra",
    cwd = wezterm.home_dir .. "/workspace/infra/terraform-resources",
    tabs = {
      { cwd = wezterm.home_dir .. "/workspace/infra/k8s-manifests" },
      { cwd = wezterm.home_dir .. "/workspace/infra/k8s-manifests", cmd = "k9s\n" },
    },
  },
}
