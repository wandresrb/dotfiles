local opt = vim.opt

-- Ponlo a true solo si tienes una Nerd Font instalada Y seleccionada en la
-- terminal. Debe definirse ANTES de cargar plugins: mini.icons, mini.statusline
-- y which-key lo consultan al hacer su setup, y si es nil se configuran sin
-- iconos (oil se queda sin ellos porque depende del mock de mini.icons).
vim.g.have_nerd_font = true

-- Números de línea (híbrido: relativo + absoluto en la actual)
opt.number = true
opt.relativenumber = true

-- Indentación
opt.tabstop = 2          -- ancho visual de un tab
opt.shiftwidth = 2       -- ancho de una indentación
opt.expandtab = true     -- tabs -> espacios
opt.smartindent = true   -- indentación inteligente

-- Búsqueda
opt.ignorecase = true    -- ignora mayúsculas...
opt.smartcase = true     -- ...salvo que escribas alguna
opt.hlsearch = false     -- no resaltar tras buscar
opt.incsearch = true     -- resaltar mientras escribes

-- Interfaz
opt.termguicolors = true -- colores de 24 bits (imprescindible para temas)
opt.signcolumn = "yes"   -- columna de signos siempre visible (evita saltos)
opt.cursorline = true    -- resalta la línea actual
opt.scrolloff = 8        -- deja 8 líneas de margen al hacer scroll
opt.wrap = false         -- no partir líneas largas

-- Plegado
--
-- OBLIGATORIO si se usa `foldmethod = expr`, que es lo que activa el autocmd de
-- treesitter (plugins/treesitter.lua). El default de Vim es foldlevel 0, o sea
-- TODO PLEGADO: abres un archivo de 500 líneas y ves 5. Con 99 entras con todo
-- desplegado y pliegas tú con `za`.
opt.foldlevelstart = 99

-- Splits (donde aparecen las ventanas nuevas)
opt.splitright = true
opt.splitbelow = true

-- Archivos y undo
opt.swapfile = false
opt.undofile = true      -- historial de deshacer persistente entre sesiones

-- Portapapeles del sistema
opt.clipboard = "unnamedplus"

-- Experiencia
opt.updatetime = 250     -- respuesta más ágil (diagnósticos, etc.)
opt.timeoutlen = 400     -- ventana para secuencias de teclas
opt.mouse = "a"          -- el ratón, por si acaso (opcional)-- ============================================================

---- vim.opt.autocomplete = true
--
-- vim.opt.completeopt = 'menu,menuone,noselect,popup'
-- vim.opt.autocompletedelay = 250
-- vim.opt.pumheight = 17
-- vim.opt.pumborder = 'rounded'
--
-- vim.opt.complete:append('o')
