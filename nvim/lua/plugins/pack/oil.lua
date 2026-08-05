-- oil: editas un directorio como un buffer de texto. Crear archivo = escribir
-- una línea; borrar = borrar la línea; renombrar = editar el texto; `:w` aplica.
require('oil').setup {
  default_file_explorer = true, -- reemplaza a netrw
  view_options = { show_hidden = true },
  columns = { 'icon' },
}

vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Abrir oil (directorio padre)' })
