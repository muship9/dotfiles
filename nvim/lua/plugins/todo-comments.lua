-- TODO : ほげ
-- NOTE : ほげ
-- WARN : ほげ
return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        TODO = {
          icon = " ",
          color = "todo",
        },
        NOTE = {
          icon = " ",
          color = "note",
          alt = { "INFO" },
        },
        WARN = {
          icon = " ",
          color = "warning",
          alt = { "WARNING", "XXX" },
        },
      },
      colors = {
        todo = { "#31748f" },    -- rose-pine pine (青緑)
        note = { "#908caa" },    -- rose-pine subtle (グレー)
        warning = { "#f6c177" }, -- rose-pine gold (オレンジ/黄色)
      },
    },
  },
}
