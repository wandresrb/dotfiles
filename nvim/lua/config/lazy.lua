-- ============================================================
-- lazy.nvim: bootstrap. Los specs están en `lua/plugins/lazy/`, uno por
-- archivo, y cada uno DEVUELVE una tabla. El `import` de abajo es el mecanismo
-- nativo de lazy — no hay escáner propio.
--
-- POR QUÉ LOS `performance` SON OBLIGATORIOS conviviendo con vim.pack:
--   * `reset_packpath = true` (default) pone `packpath = $VIMRUNTIME`, y
--     `vim.pack.add` revienta con «E919: Directory not found in 'packpath'»
--     (vim.pack instala en `stdpath('data')/site`).
--   * `rtp.reset = true` (default) reescribe el runtimepath dejando solo
--     config + VIMRUNTIME + lazy, borrando lo que vim.pack ya había añadido.
-- ============================================================

local lazypath = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy', 'lazy.nvim')
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  -- `plugins.lazy`, NUNCA `plugins` a secas: `lua/plugins/*.lua` es territorio
  -- de vim.pack y esos archivos ejecutan efectos, no devuelven specs.
  spec = { { import = 'plugins.lazy' } },
  performance = {
    reset_packpath = false, -- vim.pack necesita `site` en el packpath
    rtp = { reset = false }, -- y sus plugins ya están en el runtimepath
  },
  checker = { enabled = true, notify = false },
  ui = { border = 'rounded' },
}
