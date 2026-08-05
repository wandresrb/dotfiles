vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'config.options'
require 'config.keymaps'
require 'config.diagnostics'
require 'config.autocmd'

-- Nueva UI de mensajes/cmdline de nvim 0.12 (aún API privada).
require('vim._core.ui2').enable()

-- Los dos gestores. `config.lazy` va después: se monta sobre un
-- packpath/runtimepath ya poblado por vim.pack.
require 'config.pack' -- vim.pack   -> lua/plugins/pack/
require 'config.lazy' -- lazy.nvim  -> lua/plugins/lazy/

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
