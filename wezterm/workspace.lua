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
  { name = "voc", cwd = wezterm.home_dir .. "/workspace/voc" },
  { name = "db",  cwd = wezterm.home_dir .. "/workspace/schema" },
  {
    name = "infra",
    cwd = wezterm.home_dir,
    { cwd = wezterm.home_dir .. "/workspace/terraform-resources" },
    tabs = {
      { cwd = wezterm.home_dir .. "/workspace/k8s-manifests" },
      { cwd = wezterm.home_dir .. "/workspace/k8s-manifests", cmd = "k9s\n" },
    },
  },
}
