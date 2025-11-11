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
        todo = { "#9ccfd8" },    -- rose-pine foam (シアン)
        note = { "#908caa" },    -- rose-pine subtle (グレー)
        warning = { "#f6c177" }, -- rose-pine gold (オレンジ/黄色)
      },
    },
  },
}
