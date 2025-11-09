return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      -- Rose Pine風のパープルカラーを設定
      vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#c4a7e7' })
      vim.api.nvim_set_hl(0, 'DashboardCenter', { fg = '#e0def4' })
      vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#908caa' })

      require('dashboard').setup {
        config = {
          header = {
            '                                                     ',
            '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
            '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
            '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
            '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
            '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
            '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
            '                                                     ',
          },
        },
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  }
}
