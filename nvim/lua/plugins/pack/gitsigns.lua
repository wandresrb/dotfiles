vim.pack.add { { src = 'https://github.com/lewis6991/gitsigns.nvim' } }

require('gitsigns').setup {
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '' },
  },
  on_attach = function(bufnr)
    local gs = require 'gitsigns'
    local map = function(modo, k, fn, desc) vim.keymap.set(modo, k, fn, { buffer = bufnr, desc = desc }) end

    map('n', ']h', function() gs.nav_hunk 'next' end, 'Siguiente hunk')
    map('n', '[h', function() gs.nav_hunk 'prev' end, 'Hunk anterior')
    map({ 'n', 'x' }, '<leader>hs', gs.stage_hunk, 'Stage hunk')
    map({ 'n', 'x' }, '<leader>hr', gs.reset_hunk, 'Reset hunk')
    map('n', '<leader>hp', gs.preview_hunk, 'Previsualizar hunk')
    map('n', '<leader>hb', function() gs.blame_line { full = true } end, 'Blame de la línea')
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Objeto: hunk')
  end,
}
