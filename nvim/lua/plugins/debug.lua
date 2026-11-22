local function start_or_continue()
  local dap = require("dap")
  if dap.session() then
    return dap.continue()
  end

  if vim.bo.filetype == "python" then
    for _, config in ipairs(dap.configurations.python or {}) do
      if config.request == "launch" and config.name == "file" then
        return dap.run(vim.deepcopy(config))
      end
    end
  end

  return dap.continue()
end

return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>cv", "<cmd>PythonSelect<cr>", ft = "python", desc = "Select Python interpreter" },
      {
        "<F5>",
        start_or_continue,
        desc = "Start current file / Continue",
      },
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<S-F11>",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Condition: "))
        end,
        desc = "Conditional breakpoint",
      },
      {
        "<leader>dc",
        start_or_continue,
        desc = "Launch current file / Continue",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>dn",
        function()
          require("dap-python").test_method()
        end,
        desc = "Debug nearest test",
      },
      {
        "<leader>dC",
        function()
          require("dap-python").test_class()
        end,
        desc = "Debug test class",
      },
      {
        "<leader>dx",
        function()
          require("dap").terminate()
        end,
        desc = "Stop debug",
      },
      {
        "<leader>dM",
        function()
          require("dap").run({
            type = "python",
            request = "launch",
            name = "Module",
            module = vim.fn.input("Module: "),
            args = {},
          })
        end,
        desc = "Debug module",
      },
      {
        "<leader>dA",
        function()
          require("dap").run({
            type = "python",
            request = "attach",
            name = "Attach debugpy",
            connect = { host = "127.0.0.1", port = tonumber(vim.fn.input("Port: ", "5678")) },
            justMyCode = false,
          })
        end,
        desc = "Attach debugpy",
      },
    },
    config = function()
      -- Lazy config can be re-entered by plugin reloads; avoid duplicating
      -- Python launch configs or redefining the interpreter command.
      if vim.g._nvim_dap_configured then
        return
      end

      local dap = require("dap")
      local adapter = vim.fn.expand("~/.local/share/nvim/debugpy/bin/python")
      -- LazyVim's Python extra already adds its launch configurations. Repoint
      -- only the adapter executable here; do not append a second copy of them.
      require("dap-python").setup(adapter, { include_configs = false })
      local function py()
        if vim.g.python_selected_interpreter and vim.fn.executable(vim.g.python_selected_interpreter) == 1 then
          return vim.g.python_selected_interpreter
        end
        for _, k in ipairs({ "VIRTUAL_ENV", "CONDA_PREFIX" }) do
          local p = vim.env[k]
          if p and vim.fn.executable(p .. "/bin/python") == 1 then
            return p .. "/bin/python"
          end
        end
        for _, d in ipairs({ ".venv", "venv", "env" }) do
          local p = vim.fn.getcwd() .. "/" .. d .. "/bin/python"
          if vim.fn.executable(p) == 1 then
            return p
          end
        end
        return vim.fn.exepath("python3")
      end
      require("dap-python").resolve_python = py
      for _, c in ipairs(dap.configurations.python or {}) do
        c.pythonPath = py
        c.justMyCode = true
        c.subProcess = true
      end
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch module",
        module = function()
          return vim.fn.input("Module: ")
        end,
        args = function()
          return vim.split(vim.fn.input("Arguments: "), " ", { trimempty = true })
        end,
        pythonPath = py,
        justMyCode = true,
        subProcess = true,
      })
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Triton Interpreter",
        program = "${file}",
        pythonPath = py,
        env = { TRITON_INTERPRET = "1" },
        justMyCode = false,
        subProcess = true,
      })
      vim.api.nvim_create_user_command("PythonSelect", function()
        local paths = {}
        for _, p in ipairs({
          vim.env.VIRTUAL_ENV,
          vim.env.CONDA_PREFIX,
          vim.fn.getcwd() .. "/.venv",
          vim.fn.getcwd() .. "/venv",
        }) do
          if p then
            local x = p .. "/bin/python"
            if vim.fn.executable(x) == 1 then
              table.insert(paths, x)
            end
          end
        end
        table.insert(paths, vim.fn.exepath("python3"))
        vim.ui.select(paths, { prompt = "Python interpreter" }, function(x)
          if x then
            vim.g.python_selected_interpreter = x
            vim.notify(x)
          end
        end)
      end, { desc = "Select debug interpreter" })
      vim.g._nvim_dap_configured = true
    end,
  },
  {
    -- LazyVim's DAP extra owns setup and lifecycle listeners. Extend its opts
    -- only; never call dapui.setup() from the nvim-dap config as well.
    "rcarriga/nvim-dap-ui",
    opts = {
      floating = { border = "rounded" },
    },
  },
}
