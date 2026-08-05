-- Keymaps que NO dependen de ningún plugin.
--
-- Los de plugins viven con su plugin: telescope en plugins/telescope.lua,
-- conform en plugins/format.lua, trouble/flash/lazygit/ccc en sus specs de
-- plugins/lazy/, y los de diagnósticos en config/diagnostics.lua.

local map = vim.keymap.set

map('i', 'jk', '<Esc>', { desc = 'Salir a Normal' })
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Quitar resaltado' })
map('n', '<leader>w', '<cmd>w<cr>', { desc = 'Guardar archivo' })
map('n', '<leader>q', '<cmd>q<cr>', { desc = 'Cerrar ventana' })

map('n', '<C-h>', '<C-w>h', { desc = 'Ventana izquierda' })
map('n', '<C-j>', '<C-w>j', { desc = 'Ventana abajo' })
map('n', '<C-k>', '<C-w>k', { desc = 'Ventana arriba' })
map('n', '<C-l>', '<C-w>l', { desc = 'Ventana derecha' })

map('v', 'J', ":m '>+1<cr>gv=gv", { desc = 'Bajar selección' })
map('v', 'K', ":m '<-2<cr>gv=gv", { desc = 'Subir selección' })

-- Mantener el cursor centrado al desplazar y al saltar entre coincidencias.
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

map('x', '<leader>p', [["_dP]], { desc = 'Pegar sin sobrescribir el registro' })

-- Salir del modo terminal sin el incómodo <C-\><C-n>.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Salir del modo terminal' })
