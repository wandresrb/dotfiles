-- Saltar a cualquier sitio visible escribiendo 2 letras.
--
-- Flash se queda con `s`/`S`, sus teclas por defecto.
--
-- Ceder los `s`/`S` nativos no cuesta ninguna capacidad: son redundantes.
--   s  == cl        S  == cc        s (visual) == c
-- Lo que SÍ costaba era el default de mini.surround (`sa`/`sd`/`sr`...), que
-- convertía `s` en prefijo de 16 mapeos y metía un `timeoutlen` de espera en
-- cada pulsación. Por eso surround se movió a `gs` (ver plugins/mini.lua):
-- así `s` es de flash y de nadie más.
return {
  'folke/flash.nvim',
  opts = {},
  keys = {
    { 's', function() require('flash').jump() end, mode = { 'n', 'x', 'o' }, desc = 'Flash' },
    { 'S', function() require('flash').treesitter() end, mode = { 'n', 'x', 'o' }, desc = 'Flash Treesitter' },
  },
}
