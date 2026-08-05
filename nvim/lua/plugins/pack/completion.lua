require('luasnip').setup {}
require('luasnip.loaders.from_vscode').lazy_load()

require('blink.cmp').setup {
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
    menu = { border = 'rounded' },
  },
  signature = { enabled = true, window = { border = 'rounded' } },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
}

-- Capabilities de blink (snippets, resolve diferido) para TODOS los servidores.
vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

-- Completado inline nativo de nvim 0.12 (sugerencias tipo "ghost text" que
-- envía el propio servidor LSP, distinto del menú de blink).
vim.lsp.inline_completion.enable()
