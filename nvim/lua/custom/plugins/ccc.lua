-- ccc.nvim: resaltado de colores (#rrggbb, rgb(), hsl(), etc.) y picker interactivo.
--
-- Dos funciones principales:
--   1. Resalta colores directamente en el buffer (fondo o texto).
--   2. Picker: abre una UI para editar el valor del color con sliders.
--
-- Uso del picker:
--   Con el cursor sobre un color: `<leader>cc` abre el picker.
--   Dentro del picker: Tab/S-Tab cambia el espacio de color (RGB, HSL, etc.).

vim.pack.add { 'https://github.com/uga-rosa/ccc.nvim' }

require('ccc').setup {
  -- Resaltado automático al abrir buffers relevantes
  highlighter = {
    auto_enable = true,
    filetypes = { 'css', 'scss', 'sass', 'html', 'tsx', 'jsx', 'lua', 'typescript', 'javascript' },
  },
}

vim.keymap.set('n', '<leader>cc', '<cmd>CccPick<cr>', { desc = 'Picker de [c]olor [c]cc' })
