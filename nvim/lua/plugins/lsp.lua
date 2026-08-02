---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}
-- Automatically install LSPs and related tools to stdpath for Neovim
require('mason').setup {}
require('mason-lspconfig').setup()
require('mason-tool-installer').setup {
  ensure_installed = { 'lua_ls', 'ts_ls', 'clangd', 'html', 'cssls', 'emmet_language_server', 'just', 'tailwindcss' },
}

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- 3) Mason instala y mason-lspconfig habilita automáticamente
require('mason-lspconfig').setup {
  ensure_installed = {
    'lua_ls', -- Lua (tu config)
    'clangd', -- C / C++
    'ts_ls', -- TypeScript / JavaScript
    'tailwindcss', -- Tailwind
    'cssls',
    'html',
    'emmet_language_server',
    'jsonls',
    'yamlls',
  },
}

-- 2) Overrides por servidor (settings específicos)
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you are using
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Prevent the language server from flagging the 'vim' global variable
        globals = { 'vim' },
      },
      workspace = {
        -- Pull Neovim runtime files and API signatures into the environment
        library = {
          vim.env.VIMRUNTIME,
          -- Add this line to include plugins managed by Neovim's native pack/ system
          vim.fn.expand '$VIMRUNTIME/lua',
        },
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})
