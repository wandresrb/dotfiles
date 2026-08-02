-- Clona lazy.nvim si no existe
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', repo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- Arranca lazy cargando TODOS los archivos de lua/plugins/
require('lazy').setup {
  spec = { { import = 'plugins' } },
  install = { colorscheme = { 'catppuccin' } },
  checker = { enabled = true, notify = false }, -- avisa de actualizaciones
  ui = { border = 'rounded' },
}
