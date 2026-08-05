-- sourcekit-lsp (Swift / Objective-C).
--
-- Va en `after/lsp/` y NO en `lsp/`: nvim-lspconfig ya trae su propio
-- `lsp/sourcekit.lua`, y ambos están en el mismo nivel de precedencia
-- (`:h lsp-config-merge`, punto 2) -> el suyo ganaba y `cmd` quedaba en
-- {'sourcekit-lsp'} en vez de {'xcrun', 'sourcekit-lsp'}. `after/` gana siempre.
-- Se activa con `vim.lsp.enable 'sourcekit'` (ver lua/plugins.lua).
return {
  cmd = { 'xcrun', 'sourcekit-lsp' },
  -- Solo Swift: c/cpp/objc/objcpp los lleva clangd, y tenerlos en ambos
  -- levantaba DOS clientes LSP sobre cada buffer de C.
  filetypes = { 'swift' },
  root_markers = { 'Package.swift', '.git', 'buildServer.json' },
}
