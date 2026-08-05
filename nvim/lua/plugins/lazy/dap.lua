return {
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
    'theHamsta/nvim-dap-virtual-text',
  },
  -- OBLIGATORIO para que rustaceanvim ofrezca el codelens de Debug.
  -- rustaceanvim solo anuncia `rust-analyzer.debugSingle` a rust-analyzer si
  -- `package.loaded['dap'] ~= nil` (config/server.lua:69), y esas capabilities
  -- se construyen al crear el cliente, en el FileType de un buffer Rust.
  -- `BufReadPre` dispara ANTES que `FileType`, así que aquí llegamos a tiempo.
  -- Sin esto solo hay un codelens (Run) y `grx` lo ejecuta sin preguntar.
  event = { { event = 'BufReadPre', pattern = '*.rs' } },
  keys = {
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Breakpoint' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'Continuar' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'Step into' },
    { '<leader>do', function() require('dap').step_over() end, desc = 'Step over' },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'UI de debug' },
  },
  config = function()
    local dap, dapui = require 'dap', require 'dapui'
    require('nvim-dap-virtual-text').setup()
    dapui.setup()
    -- Abre/cierra la UI automáticamente con la sesión
    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
  end,
}
