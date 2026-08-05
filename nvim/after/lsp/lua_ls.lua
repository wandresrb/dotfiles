-- Override de lua_ls sobre la config que trae nvim-lspconfig.
--
-- Va en `after/lsp/` a propósito: los `lsp/<nombre>.lua` de tu config y los de
-- nvim-lspconfig están en el MISMO nivel de precedencia y se fusionan según el
-- orden del runtimepath. `after/` es el único nivel que gana siempre
-- (`:h lsp-config-merge`, punto 3).
return {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.expand '$VIMRUNTIME/lua',
        },
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}
