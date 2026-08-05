-- Telescope: setup, extensiones, keymaps y los pickers LSP.
--
-- Si algún día cambias de picker (snacks, fzf-lua), este es el ÚNICO archivo
-- a tocar: los mapeos `gr*` de LSP también están aquí.

require('telescope').setup {
  extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
}

-- En pcall a propósito: fzf necesita compilarse (ver el build hook de
-- plugins/init.lua) y ui-select puede no estar instalado todavía.
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
local function map(keys, fn, desc, mode) vim.keymap.set(mode or 'n', keys, fn, { desc = desc }) end

map('<leader>sh', builtin.help_tags, '[S]earch [H]elp')
map('<leader>sk', builtin.keymaps, '[S]earch [K]eymaps')
map('<leader>sf', builtin.find_files, '[S]earch [F]iles')
map('<leader>ss', builtin.builtin, '[S]earch [S]elect Telescope')
map('<leader>sw', builtin.grep_string, '[S]earch current [W]ord', { 'n', 'v' })
map('<leader>sg', builtin.live_grep, '[S]earch by [G]rep')
map('<leader>sd', builtin.diagnostics, '[S]earch [D]iagnostics')
map('<leader>sr', builtin.resume, '[S]earch [R]esume')
map('<leader>sc', builtin.commands, '[S]earch [C]ommands')
map('<leader>s.', builtin.oldfiles, '[S]earch Recent Files')
map('<leader><leader>', builtin.buffers, '[ ] Find existing buffers')
map('<leader>s/', function() builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' } end, '[S]earch [/] in Open Files')
map('<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, '[S]earch [N]eovim files')
map('<leader>/', function() builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false }) end, '[/] Buscar en el buffer actual')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(ev)
    local function bmap(keys, fn, desc) vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = desc }) end
    bmap('grr', builtin.lsp_references, '[G]oto [R]eferences')
    bmap('gri', builtin.lsp_implementations, '[G]oto [I]mplementation')
    bmap('grd', builtin.lsp_definitions, '[G]oto [D]efinition')
    bmap('grt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
    bmap('gO', builtin.lsp_document_symbols, 'Open Document Symbols')
    bmap('gW', builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
  end,
})
