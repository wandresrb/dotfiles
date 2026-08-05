-- nvim-treesitter-textobjects: MOVIMIENTO, REPETICIÓN e INTERCAMBIO.
--
-- La SELECCIÓN (`af`, `if`, `ac`, ...) NO se define aquí: la hace mini.ai en
-- plugins/mini.lua leyendo estas mismas queries. El motivo está explicado allí:
-- mini.ai mapea `a`/`i` como teclas sueltas, así que un `af` extra las
-- volvería prefijos ambiguos y metería un `timeoutlen` de espera en cada `a`.
--
-- Aquí va lo que mini.ai NO sabe hacer:
--   * saltar entre nodos            -> `]f` `[f` `]F` `[F` ...
--   * repetir el último salto       -> `;` y `,`
--   * intercambiar nodos hermanos   -> `<leader>c*`

require('nvim-treesitter-textobjects').setup {
  select = { lookahead = true },
  move = { set_jumps = true }, -- deja el salto en la jumplist (<C-o> vuelve)
}

local move = require 'nvim-treesitter-textobjects.move'
local swap = require 'nvim-treesitter-textobjects.swap'
local repeatable = require 'nvim-treesitter-textobjects.repeatable_move'

local modes = { 'n', 'x', 'o' }

-- ------------------------------------------------------------
-- Movimiento
--
-- Las teclas usan `]`/`[`, que Vim reserva justo para "ir al siguiente/anterior
-- elemento". Minúscula salta al INICIO del nodo, mayúscula al FINAL — la misma
-- convención que `]m`/`]M` nativos para métodos.
--
-- Se envuelven en `make_repeatable_move` para que `;` y `,` los repitan.
-- ------------------------------------------------------------

for key, capture in pairs {
  f = '@function.outer',
  c = '@class.outer',
  a = '@parameter.inner',
  o = '@loop.outer',
  k = '@call.outer',
  m = '@comment.outer',
  r = '@return.outer',
} do
  local next_start = repeatable.make_repeatable_move(function() move.goto_next_start(capture, 'textobjects') end)
  local prev_start = repeatable.make_repeatable_move(function() move.goto_previous_start(capture, 'textobjects') end)
  local next_end = repeatable.make_repeatable_move(function() move.goto_next_end(capture, 'textobjects') end)
  local prev_end = repeatable.make_repeatable_move(function() move.goto_previous_end(capture, 'textobjects') end)

  vim.keymap.set(modes, ']' .. key, next_start, { desc = 'Inicio siguiente ' .. capture })
  vim.keymap.set(modes, '[' .. key, prev_start, { desc = 'Inicio anterior ' .. capture })
  vim.keymap.set(modes, ']' .. key:upper(), next_end, { desc = 'Final siguiente ' .. capture })
  vim.keymap.set(modes, '[' .. key:upper(), prev_end, { desc = 'Final anterior ' .. capture })
end

-- ------------------------------------------------------------
-- Repetición
--
-- `;` y `,` repiten el ÚLTIMO salto, sea de treesitter o el `f`/`t` nativo.
-- Los cuatro mapeos `expr` de abajo son los que hacen que `f`/`F`/`t`/`T`
-- registren su salto: sin ellos, `;` seguiría repitiendo el último `]f` en vez
-- del `fx` que acabas de escribir. No se pierde nada del comportamiento nativo.
-- ------------------------------------------------------------

vim.keymap.set(modes, ';', repeatable.repeat_last_move, { desc = 'Repetir último salto' })
vim.keymap.set(modes, ',', repeatable.repeat_last_move_opposite, { desc = 'Repetir último salto (al revés)' })

vim.keymap.set(modes, 'f', repeatable.builtin_f_expr, { expr = true, desc = 'Ir a carácter (repetible)' })
vim.keymap.set(modes, 'F', repeatable.builtin_F_expr, { expr = true, desc = 'Ir a carácter atrás (repetible)' })
vim.keymap.set(modes, 't', repeatable.builtin_t_expr, { expr = true, desc = 'Hasta carácter (repetible)' })
vim.keymap.set(modes, 'T', repeatable.builtin_T_expr, { expr = true, desc = 'Hasta carácter atrás (repetible)' })

-- ------------------------------------------------------------
-- Intercambio
--
-- En `<leader>c` (Code), pero NO en `<leader>ca`: esa es la code action del LSP.
-- ------------------------------------------------------------

for key, capture in pairs {
  p = '@parameter.inner', -- reordenar argumentos
  f = '@function.outer', -- mover una función entera arriba/abajo
} do
  vim.keymap.set('n', '<leader>c' .. key, function() swap.swap_next(capture) end, { desc = 'Intercambiar ' .. capture .. ' con el siguiente' })
  vim.keymap.set('n', '<leader>c' .. key:upper(), function() swap.swap_previous(capture) end, { desc = 'Intercambiar ' .. capture .. ' con el anterior' })
end
