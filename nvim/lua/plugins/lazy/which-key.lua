-- Muestra los mapeos pendientes al empezar una secuencia de teclas.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    -- Solo NOMBRA los prefijos; los mapeos se definen donde toca.
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>g', group = '[G]it' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>x', group = 'Diagnósticos' },
      { '<leader>c', group = '[C]ode' },
      { '<leader>p', group = '[P]ack' },
      { 'gr', group = 'LSP Actions' },
      { 'gs', group = 'Surround' },
    },
  },
}
