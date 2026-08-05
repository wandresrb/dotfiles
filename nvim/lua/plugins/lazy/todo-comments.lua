-- Resalta TODO, FIX, HACK, NOTE... en los comentarios.
--
-- Usa plenary, que ya instala vim.pack: por eso NO se declara `dependencies`
-- (lazy intentaría instalar una segunda copia).
return { 'folke/todo-comments.nvim', event = 'VeryLazy', opts = { signs = false } }
