-- Configuración de diagnósticos. Ver `:help vim.diagnostic.Opts`.
-- Los keymaps `[d` / `]d` son nativos desde nvim 0.11.

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  virtual_text = true, -- el mensaje al final de la línea
  virtual_lines = false, -- alternativa: debajo de la línea, en líneas virtuales

  -- Abre el flotante al saltar con `[d` / `]d`, para leer el error sin pasos extra.
  jump = {
    on_jump = function(_, bufnr) vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false } end,
  },
}

vim.keymap.set('n', '<leader>xq', vim.diagnostic.setloclist, { desc = 'Diagnósticos -> loclist' })
