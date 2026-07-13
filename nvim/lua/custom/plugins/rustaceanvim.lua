-- rustaceanvim: soporte Rust en Neovim (sucesor de rust-tools.nvim).
--
-- A diferencia de otros plugins, NO se le llama `.setup()` y NO se configura
-- vía lspconfig: rustaceanvim arranca y gestiona su propio rust-analyzer.
-- Su "configuración" es la tabla `vim.g.rustaceanvim`, que debe estar
-- definida antes de abrir el primer buffer Rust.
--
-- IMPORTANTE: no descomentar `rust_analyzer` en la tabla `servers` de
-- init.lua; tendrías dos clientes LSP sobre el mismo buffer.

vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ['rust-analyzer'] = {
        check = { command = 'clippy' }, -- check-on-save con clippy
        cargo = { allFeatures = true },
      },
    },
  },
}

-- Instala el plugin. `vim.pack.add` clona el repo la primera vez (síncrono).
vim.pack.add { 'https://github.com/mrcjkb/rustaceanvim' }
