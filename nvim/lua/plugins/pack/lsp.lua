-- LSP: qué instalar y qué habilitar.
--
-- Las configs POR SERVIDOR no están aquí: son archivos que devuelven una tabla
-- en `after/lsp/<nombre>.lua` (ver `:h lsp-config`). Van en `after/` y no en
-- `lsp/` porque nvim-lspconfig trae los suyos en el mismo nivel de precedencia
-- y ganaba el suyo; `after/` gana siempre (`:h lsp-config-merge`, punto 3).

local servers = {
  'lua_ls',
  'clangd',
  'ts_ls',
  'tailwindcss',
  'cssls',
  'html',
  'emmet_language_server',
  'jsonls',
  'yamlls',
}

require('mason').setup {}

-- `automatic_enable = false` es IMPORTANTE: en `true` mason-lspconfig habilita
-- CUALQUIER servidor instalado en mason, esté o no en `servers`. Eso arrancaba
-- un rust_analyzer extra que chocaba con el de rustaceanvim (dos clientes en el
-- mismo buffer -> diagnósticos y avisos duplicados).
require('mason-lspconfig').setup { automatic_enable = false }

-- `stylua` no es un servidor LSP, pero sí una herramienta que instala mason:
-- la pide conform para formatear Lua al guardar (hay .stylua.toml en el repo).
require('mason-tool-installer').setup { ensure_installed = vim.list_extend(vim.deepcopy(servers), { 'stylua' }) }

vim.lsp.enable(servers)
vim.lsp.enable 'sourcekit' -- after/lsp/sourcekit.lua

-- rustaceanvim gestiona su propio rust-analyzer: no lleva `.setup()` ni pasa
-- por lspconfig, y por eso `rust_analyzer` NO está en `servers`.
-- Su configuración es esta tabla, y debe existir antes del primer buffer Rust.
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ['rust-analyzer'] = {
        check = { command = 'clippy' },
        cargo = { allFeatures = true },
      },
    },
  },
}

require('crates').setup {
  completion = { crates = { enabled = true } },
  lsp = { enabled = true, actions = true, completion = true, hover = true },
}
