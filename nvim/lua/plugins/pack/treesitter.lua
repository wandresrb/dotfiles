-- Treesitter: parsers, highlight, folds, indent, y autotag (que lo usa).

require('nvim-treesitter').install {
  'bash',
  'c',
  'diff',
  'html',
  'just',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'rust',
  'swift',
  'vim',
  'vimdoc',
}

-- OJO: `FileType` va por FILETYPE, no por nombre de parser (`markdown_inline`,
-- `luadoc`, `query` o `diff` no son filetypes). Por eso el lenguaje se resuelve
-- en el callback en vez de filtrar con `pattern = parsers`.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang or not vim.treesitter.language.add(lang) then return end

    vim.treesitter.start(args.buf, lang)

    -- `vim.wo[0][0]` y no `vim.wo`: fija la opción window-local PARA ESTE
    -- BUFFER. Con `vim.wo` a secas, al abrir otro archivo en la misma ventana
    -- se arrastran el foldmethod/foldexpr de treesitter aunque ese buffer no
    -- tenga parser. Requiere `foldlevelstart = 99` (config/options.lua) o los
    -- archivos se abren plegados.
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'

    -- Sin query de `indents`, el indentexpr de treesitter no aporta nada
    -- y el fallback nativo de vim es mejor.
    if vim.treesitter.query.get(lang, 'indents') then vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end,
})

-- Cierra y renombra etiquetas HTML/JSX en pareja (necesita los parsers html/tsx).
require('nvim-ts-autotag').setup {
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false, -- off: duplicaría el cierre
  },
}
