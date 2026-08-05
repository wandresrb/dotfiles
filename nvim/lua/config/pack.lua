-- ============================================================
-- vim.pack: bootstrap.
--
-- Simétrico a `config/lazy.lua`: aquí solo va la maquinaria del gestor
-- (qué se instala, build hooks, actualizar). Las CONFIGS de cada plugin viven
-- en `lua/plugins/pack/*.lua` y se cargan solas — añade un archivo ahí y ya
-- está, igual que en `lua/plugins/lazy/`.
-- ============================================================

local function gh(repo) return 'https://github.com/' .. repo end

local specs = {
  -- 'neovim' a secas es demasiado genérico como nombre de directorio.
  { src = gh 'rose-pine/neovim', name = 'rose-pine' },
  gh 'nvim-mini/mini.nvim',
  gh 'nvim-treesitter/nvim-treesitter',
  -- `version = 'main'` es OBLIGATORIO: la rama por defecto (master) es la vieja
  -- API, incompatible con el nvim-treesitter nuevo.
  { src = gh 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  gh 'windwp/nvim-ts-autotag',
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  gh 'mrcjkb/rustaceanvim',
  gh 'saecki/crates.nvim',
  gh 'L3MON4D3/LuaSnip',
  gh 'rafamadriz/friendly-snippets',
  { src = gh 'saghen/blink.cmp', version = '1.*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
  gh 'stevearc/conform.nvim',
  gh 'mfussenegger/nvim-lint',
  gh 'stevearc/oil.nvim',
  gh 'NMAC427/guess-indent.nvim',
  gh 'j-hui/fidget.nvim',
}

-- El sorter nativo de telescope hay que compilarlo; sin `make` no sirve de nada.
if vim.fn.executable 'make' == 1 then table.insert(specs, gh 'nvim-telescope/telescope-fzf-native.nvim') end

vim.pack.add(specs)

-- ------------------------------------------------------------
-- Build hook
--
-- `vim.pack` no tiene `build = ...` como lazy.nvim: dispara el autocmd
-- `PackChanged` con `data = { kind, spec, path }`, kind ∈ install|update|delete.
-- ------------------------------------------------------------

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack-build', { clear = true }),
  callback = function(ev)
    local d = ev.data
    -- Sin este `make`, `load_extension('fzf')` falla en silencio (va en pcall)
    -- y pierdes el sorter nativo sin enterarte.
    if d.spec.name ~= 'telescope-fzf-native.nvim' then return end
    if d.kind ~= 'install' and d.kind ~= 'update' then return end
    vim.system({ 'make' }, { cwd = d.path }, function(out)
      local ok = out.code == 0
      local msg = ok and 'telescope-fzf-native: build ok' or ('telescope-fzf-native: build falló\n' .. (out.stderr or ''))
      vim.schedule(function() vim.notify(msg, ok and vim.log.levels.INFO or vim.log.levels.ERROR) end)
    end)
  end,
})

-- ------------------------------------------------------------
-- Gestión
--
-- OJO con `<leader>pu`: abre una pestaña de confirmación y NO aplica nada
-- hasta que hagas `:w` ahí (`:q` descarta). Luego `:restart` para usar el
-- código nuevo.
-- ------------------------------------------------------------

vim.keymap.set('n', '<leader>pu', function() vim.pack.update() end, { desc = '[P]ack [U]pdate (confirma con :w)' })
vim.keymap.set('n', '<leader>pl', function()
  local lines = vim.tbl_map(function(p) return ('%-32s %s'):format(p.spec.name, p.active and 'activo' or 'inactivo') end, vim.pack.get())
  table.sort(lines)
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end, { desc = '[P]ack [L]ist' })

-- ------------------------------------------------------------
-- Carga de `lua/plugins/pack/*.lua`
--
-- La lista `ordered` existe porque el orden alfabético no vale: `mini` iría
-- antes que `textobjects`, y mini.ai necesita sus queries. Solo van aquí los
-- que tienen una dependencia real entre sí. Todo lo demás se carga después,
-- ordenado alfabéticamente para que sea determinista (`vim.fs.dir` no
-- garantiza ningún orden).
-- ------------------------------------------------------------

local ordered = {
  'treesitter', -- instala parsers y queries
  'textobjects', -- antes que mini: mini.ai lee sus queries
  'mini', -- registra los iconos que usan telescope y oil
  'completion', -- registra las capabilities en la config LSP '*'
  'lsp', -- hace el `vim.lsp.enable`, ya con esas capabilities
}

local done = {}
for _, name in ipairs(ordered) do
  done[name] = true
  require('plugins.pack.' .. name)
end

local rest = {}
for entry, entry_type in vim.fs.dir(vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins', 'pack')) do
  local name = entry:match '^(.+)%.lua$'
  if (entry_type == 'file' or entry_type == 'link') and name and not done[name] then rest[#rest + 1] = name end
end
table.sort(rest)

for _, name in ipairs(rest) do
  require('plugins.pack.' .. name)
end
