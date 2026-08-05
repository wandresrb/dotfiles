-- Resalta colores en el buffer y abre un picker con sliders sobre el color
-- bajo el cursor (Tab dentro del picker cambia RGB/HSL/...).
local filetypes = { 'css', 'scss', 'sass', 'html', 'tsx', 'jsx', 'lua', 'typescript', 'javascript' }
return {
  'uga-rosa/ccc.nvim',
  ft = filetypes,
  cmd = { 'CccPick', 'CccHighlighterToggle' },
  keys = { { '<leader>cc', '<cmd>CccPick<cr>', desc = 'Picker de [c]olor [c]cc' } },
  opts = { highlighter = { auto_enable = true, filetypes = filetypes } },
}
