-- Formateo (conform) y linting (nvim-lint).

require('conform').setup {
  notify_on_error = false,
  formatters_by_ft = {
    lua = { 'stylua' },
    rust = { 'rustfmt' },
  },
  -- Solo formatea al guardar los filetypes de esta lista; el resto, a mano
  -- con <leader>f.
  format_on_save = function(bufnr)
    local enabled = { lua = true, rust = true }
    return enabled[vim.bo[bufnr].filetype] and { timeout_ms = 500 } or nil
  end,
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

-- Sin `linters_by_ft` nvim-lint no ejecuta NADA. Añade aquí los linters por
-- filetype, y su binario a `ensure_installed` en plugins/lsp.lua.
--   ej.  markdown = { 'markdownlint' },
require('lint').linters_by_ft = {}

vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = function() require('lint').try_lint() end,
})
