return {
  "github/copilot.vim",
  lazy = false,
  config = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function()
        local filepath = vim.fn.expand("%:p")
        if filepath:match("^" .. vim.env.HOME .. "/memo") then
          vim.cmd("Copilot disable")
        else
          vim.cmd("Copilot enable")
        end
      end,
    })
  end,
}
