-- nvim-ts-autotag: cierre y renombrado automático de etiquetas HTML/JSX.
--
-- Qué hace (usa treesitter, por eso necesita los parsers html/tsx instalados):
--   1. Al escribir `<div>` cierra solo con `</div>`.
--   2. Al renombrar la etiqueta de apertura, actualiza la de cierre (y viceversa).
--   3. `<div></div>` + Enter deja el cursor indentado en medio.
--
-- Funciona en: html, xml, jsx, tsx, vue, svelte, php, markdown, etc.

vim.pack.add { 'https://github.com/windwp/nvim-ts-autotag' }

require('nvim-ts-autotag').setup {
  opts = {
    enable_close = true, -- cierra la etiqueta al escribir '>'
    enable_rename = true, -- renombra el par al editar una etiqueta
    enable_close_on_slash = false, -- cerrar al escribir '</' (off para no duplicar)
  },
}
