-- mini.nvim: icons, ai (textobjects), surround, pairs, statusline.

if vim.g.have_nerd_font then
  require('mini.icons').setup()
  -- Compatibilidad con plugins que aún piden `nvim-web-devicons` (telescope, oil).
  MiniIcons.mock_nvim_web_devicons()
end

-- Textobjects. mini.ai es el ÚNICO dueño de los prefijos `a` e `i`.
--
-- POR QUÉ NO USAMOS el módulo `select` de nvim-treesitter-textobjects:
-- mini.ai mapea `a` e `i` como teclas SUELTAS que leen el siguiente carácter.
-- Si otro plugin mapeara además `af`, `a` pasaría a ser prefijo ambiguo y
-- Neovim esperaría `timeoutlen` en CADA pulsación de `a`. En vez de eso,
-- `gen_spec.treesitter` lee las MISMAS queries del plugin (por eso se carga
-- antes, ver plugins/init.lua) y las expone por mini.ai, que encima añade
-- sufijos next/last y soporte de count: `cinf` = change inside next function,
-- `v2af` = selecciona 2 funciones.
--
-- Lo que se pierde frente a `select`: selección linewise por captura
-- (`selection_modes`) e `include_surrounding_whitespace`. Es decir, `daf` deja
-- la línea vacía en vez de borrarla entera.
--
-- Movimiento (`]f`), repetición (`;`) y swap NO están aquí: eso sí lo hace el
-- plugin, en plugins/textobjects.lua, sobre teclas que no chocan.
local ts = require('mini.ai').gen_spec.treesitter

require('mini.ai').setup {
  n_lines = 500,
  -- MAYÚSCULAS a propósito. Los defaults (`an`/`in`) chocan con la selección
  -- incremental nativa de nvim >= 0.12 (`an` = Select parent node), y usar
  -- `aa`/`al` en su lugar tapaba los objetos `a` (argumento) y `l`.
  mappings = {
    around_next = 'aN',
    inside_next = 'iN',
    around_last = 'aL',
    inside_last = 'iL',
  },
  -- Todas las capturas que traen las queries. Las que un lenguaje no define
  -- simplemente no encuentran nada (p.ej. `ac` en Lua: no hay clases).
  --   f función   c clase      o bucle/condicional   k llamada
  --   m comentario r return    g asignación          d bloque
  --   s sentencia  n número    x atributo (html)
  -- Se mantienen los builtins de mini.ai que NO son de treesitter y por tanto
  -- funcionan en archivos sin parser: `q` comillas, `b` brackets, `t` tags,
  -- `a` argumentos.
  custom_textobjects = {
    f = ts { a = '@function.outer', i = '@function.inner' },
    c = ts { a = '@class.outer', i = '@class.inner' },
    o = ts { a = { '@loop.outer', '@conditional.outer' }, i = { '@loop.inner', '@conditional.inner' } },
    k = ts { a = '@call.outer', i = '@call.inner' },
    m = ts { a = '@comment.outer', i = '@comment.inner' },
    r = ts { a = '@return.outer', i = '@return.inner' },
    g = ts { a = '@assignment.outer', i = '@assignment.inner' },
    d = ts { a = '@block.outer', i = '@block.inner' },
    s = ts { a = '@statement.outer', i = '@statement.outer' },
    n = ts { a = '@number.inner', i = '@number.inner' },
    x = ts { a = '@attribute.outer', i = '@attribute.inner' },
  },
}

-- Surround bajo el prefijo `gs`, NO bajo `s`.
--
-- El default (`sa`/`sd`/`sr`/...) ocupa 16 mapeos que empiezan por `s`. Eso
-- convierte `s` en prefijo, y con flash mapeado a `s` a secas Neovim tendría
-- que esperar `timeoutlen` en CADA pulsación para desambiguar — las dos
-- features quedaban no deterministas.
--
-- Se cede el `gs` nativo («go to sleep for N seconds»), que no lo usa nadie,
-- a cambio de dejar `s` limpio para flash.
--
--   gsa)  añadir      gsd'  borrar      gsr)' reemplazar
--   gsf   buscar      gsh   resaltar
--
-- n_lines 500 (default 20) porque en SVG/HTML el cierre de un <g>/<div>
-- puede estar a cientos de líneas.
require('mini.surround').setup {
  n_lines = 500,
  mappings = {
    add = 'gsa',
    delete = 'gsd',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    replace = 'gsr',
    update_n_lines = 'gsn',
    suffix_last = 'l',
    suffix_next = 'n',
  },
}

require('mini.pairs').setup {}

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end
