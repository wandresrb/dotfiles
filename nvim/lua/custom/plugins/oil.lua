-- oil.nvim: explorador de archivos que se edita como un buffer normal.
--
-- La idea central de oil: en vez de un árbol lateral (tipo NvimTree), abres
-- un directorio como si fuera un archivo de texto. Crear un archivo = escribir
-- una línea nueva. Borrar = borrar la línea. Renombrar = editar el texto.
-- Mover = cortar/pegar la línea. Al guardar con `:w`, oil aplica los cambios
-- en disco.
--
-- A diferencia de rustaceanvim, oil SÍ necesita `.setup()` para activarse.

-- Paso 1: descargar el plugin (síncrono la primera vez).
vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

-- Paso 2: activarlo y configurarlo.
require('oil').setup {
  -- Hacer que oil reemplace a netrw (el explorador nativo de vim).
  default_file_explorer = true,

  view_options = {
    show_hidden = true, -- mostrar archivos ocultos (dotfiles) por defecto
  },

  -- Columnas que muestra cada entrada. `icon` necesita una nerd font.
  columns = {
    'icon',
  },

  -- Abrir oil en una ventana flotante con la tecla por defecto sigue igual,
  -- pero dejamos los keymaps internos por defecto (son sensatos):
  --   `<CR>`  abrir archivo/carpeta
  --   `-`     subir al directorio padre
  --   `g?`    ayuda con todos los atajos disponibles
  --   `<C-s>` abrir en split vertical
}

-- Paso 3: un atajo para ABRIR oil. La convención de oil es la tecla `-`,
-- que abre el directorio del archivo actual.
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Abrir oil (directorio padre)' })
