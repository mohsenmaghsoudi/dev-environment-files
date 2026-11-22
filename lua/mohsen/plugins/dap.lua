-- lua/mohsen/plugins/dap.lua
-- ══════════════════════════════════════════════════════════════
--  Debug Adapter Protocol: Go (Delve) + Python (debugpy) + C# / .NET (netcoredbg)
--
--  Global keys (F-keys need fn on a Mac, so each has a leader equivalent):
--    F5    continue / start
--    F9    toggle breakpoint   <leader>dd
--    F10   step over           <leader>dn
--    F11   step into           <leader>di
--    S-F11 step out            <leader>do
--    <leader>dC  run to cursor
--
--  Go:      <leader>Go debug test,   <leader>GL debug last test
--  Python:  <leader>Pm test method,  <leader>Pc test class
--  C#:      <leader>Co continue,     <leader>Cb toggle breakpoint
--
--  Requirements:
--    Go     -> delve (mason)
--    Python -> debugpy (mason)
--    C#     -> netcoredbg: :NetcoredbgInstall (Mason's package is broken)
-- ══════════════════════════════════════════════════════════════
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "williamboman/mason.nvim",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local util = require("mohsen.dap_util")

      -- ────────────────────────────────────────────────────────
      -- Breakpoint sign icons and colors
      -- ────────────────────────────────────────────────────────
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticError", linehl = "", numhl = "" })

      -- ══════════════════════════════════════════════════════════
      -- Go / Delve
      -- Options live in dap_util.go_opts so neotest-golang gets the same ones
      -- ══════════════════════════════════════════════════════════
      require("dap-go").setup(util.go_opts())

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          vim.keymap.set("n", "<leader>Go", function()
            require("dap-go").debug_test()
          end, { desc = "DAP Go: Debug Test", buffer = true })
          vim.keymap.set("n", "<leader>GL", function()
            require("dap-go").debug_last_test()
          end, { desc = "DAP Go: Debug Last Test", buffer = true })
        end,
      })

      -- ══════════════════════════════════════════════════════════
      -- Python (debugpy)
      -- The adapter runs with Mason's own debugpy (independent of the project);
      -- the program itself runs with the project venv: the venv-selector choice
      -- if there is one, otherwise VIRTUAL_ENV / .venv / venv (dap-python logic)
      -- ══════════════════════════════════════════════════════════
      local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      if vim.fn.has("win32") == 1 then
        debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/Scripts/python.exe"
      end
      local has_mason_debugpy = vim.fn.executable(debugpy_python) == 1
      if not has_mason_debugpy then
        -- fallback: system python (must have debugpy installed)
        debugpy_python = vim.fn.exepath("python3")
      end

      local ok_dappy, dappy = pcall(require, "dap-python")
      if ok_dappy then
        dappy.setup(debugpy_python)
        dappy.test_runner = "pytest"

        -- Extra config: also step into library code
        table.insert(dap.configurations.python, {
          type = "python",
          request = "launch",
          name = "Launch file (justMyCode=false)",
          program = "${file}",
          justMyCode = false,
        })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "python",
          once = true, -- warn only once
          callback = function()
            if not has_mason_debugpy then
              vim.notify(
                "debugpy is not installed in Mason: :MasonInstall debugpy\n(falling back to the system python3)",
                vim.log.levels.WARN,
                { title = "DAP Python" }
              )
            end
          end,
        })
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "python",
          callback = function()
            vim.keymap.set("n", "<leader>Pm", function()
              dappy.test_method()
            end, { desc = "Python DAP: Debug Method", buffer = true })
            vim.keymap.set("n", "<leader>Pc", function()
              dappy.test_class()
            end, { desc = "Python DAP: Debug Class", buffer = true })
          end,
        })
      end

      -- ══════════════════════════════════════════════════════════
      -- C# / .NET  (netcoredbg)
      -- The adapter is a function so that, if netcoredbg is missing, you get a
      -- clear message instead of a vague error.
      -- ══════════════════════════════════════════════════════════
      dap.adapters.coreclr = function(callback)
        local cmd = util.find_netcoredbg()
        if not cmd then
          vim.notify(
            "netcoredbg not found.\nRun in nvim:  :NetcoredbgInstall",
            vim.log.levels.ERROR,
            { title = "DAP .NET" }
          )
          return
        end
        callback({ type = "executable", command = cmd, args = { "--interpreter=vscode" } })
      end
      -- Also register under the name netcoredbg (used by neotest-vstest)
      dap.adapters.netcoredbg = dap.adapters.coreclr

      vim.api.nvim_create_user_command("NetcoredbgInstall", util.install_netcoredbg, {
        desc = "Download and install netcoredbg (arm64) without Mason",
      })

      -- Find runnable dlls (not libraries, not tests); newest build first
      local function find_dlls(cwd)
        local out = {}
        local rcs = vim.fn.glob(cwd .. "/**/bin/Debug/**/*.runtimeconfig.json", true, true)
        for _, rc in ipairs(rcs) do
          local dll = rc:gsub("%.runtimeconfig%.json$", ".dll")
          local name = vim.fn.fnamemodify(dll, ":t:r")
          local is_test = name:match("[Tt]ests?$") or name:match("%.Tests?%.") or name == "testhost"
          if not is_test and vim.fn.filereadable(dll) == 1 then
            table.insert(out, { path = dll, mtime = vim.fn.getftime(dll) })
          end
        end
        table.sort(out, function(a, b)
          return a.mtime > b.mtime
        end)
        return vim.tbl_map(function(x)
          return x.path
        end, out)
      end

      -- First dotnet build (async, nvim does not freeze), then pick a dll.
      -- Uses nvim-dap's documented coroutine model.
      local function dotnet_program()
        return coroutine.create(function(dap_co)
          local cwd = vim.fn.getcwd()
          vim.notify("dotnet build …", vim.log.levels.INFO, { title = "DAP .NET" })

          vim.system({ "dotnet", "build", "--nologo", "-v", "q" }, { text = true, cwd = cwd }, function(res)
            vim.schedule(function()
              if res.code ~= 0 then
                vim.notify(
                  "dotnet build failed:\n" .. (res.stdout or "") .. (res.stderr or ""),
                  vim.log.levels.ERROR,
                  { title = "DAP .NET" }
                )
                return coroutine.resume(dap_co, dap.ABORT)
              end

              local dlls = find_dlls(cwd)
              if #dlls == 0 then
                local p = vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
                return coroutine.resume(dap_co, p ~= "" and p or dap.ABORT)
              elseif #dlls == 1 then
                return coroutine.resume(dap_co, dlls[1])
              end

              vim.ui.select(dlls, {
                prompt = "Which project to debug?",
                format_item = function(f)
                  return vim.fn.fnamemodify(f, ":t:r") .. "   (" .. vim.fn.fnamemodify(f, ":.") .. ")"
                end,
              }, function(choice)
                coroutine.resume(dap_co, choice or dap.ABORT)
              end)
            end)
          end)
        end)
      end

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch: Console / .NET App",
          request = "launch",
          program = dotnet_program,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          console = "integratedTerminal",
          env = { DOTNET_ENVIRONMENT = "Development" },
        },
        {
          type = "coreclr",
          name = "Launch: ASP.NET Core",
          request = "launch",
          program = dotnet_program,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          console = "integratedTerminal",
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
            -- Port 5000 is taken by AirPlay Receiver on macOS
            ASPNETCORE_URLS = "http://localhost:5180",
          },
        },
        {
          type = "coreclr",
          name = "Attach: .NET Process",
          request = "attach",
          processId = function()
            return require("dap.utils").pick_process({ filter = "dotnet" })
          end,
        },
      }
      dap.configurations.fsharp = dap.configurations.cs

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        callback = function()
          vim.keymap.set("n", "<leader>Co", dap.continue, { desc = "C# DAP: Continue", buffer = true })
          vim.keymap.set("n", "<leader>Cb", dap.toggle_breakpoint, { desc = "C# DAP: Toggle Breakpoint", buffer = true })
        end,
      })

      -- ══════════════════════════════════════════════════════════
      -- DAP UI + Virtual Text
      -- ══════════════════════════════════════════════════════════
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            position = "left",
            size = 42,
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "stacks", size = 0.30 },
              { id = "watches", size = 0.20 },
              { id = "breakpoints", size = 0.15 },
            },
          },
          {
            position = "bottom",
            size = 12,
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
          },
        },
        floating = {
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } },
        },
      })

      require("nvim-dap-virtual-text").setup({
        enabled = true,
        highlight_changed_variables = true,
        show_stop_reason = true,
        virt_text_pos = "eol",
      })

      -- Open/close the UI automatically (also works for neotest debug runs)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- ══════════════════════════════════════════════════════════
      -- Global keymaps
      -- ══════════════════════════════════════════════════════════
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { desc = "DAP: " .. desc })
      end

      map("<F5>", dap.continue, "Continue / Start")
      map("<F10>", dap.step_over, "Step Over")
      map("<F11>", dap.step_into, "Step Into")
      map("<S-F11>", dap.step_out, "Step Out")
      map("<F9>", dap.toggle_breakpoint, "Toggle Breakpoint")

      -- Leader equivalents (F-keys often clash with system keys on a Mac)
      map("<leader>dd", dap.toggle_breakpoint, "Toggle Breakpoint")
      map("<leader>dn", dap.step_over, "Step Over (next)")
      map("<leader>di", dap.step_into, "Step Into")
      map("<leader>do", dap.step_out, "Step Out")
      map("<leader>dC", dap.run_to_cursor, "Run to Cursor")

      map("<leader>db", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "Conditional Breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
      end, "Log Breakpoint")

      map("<leader>dr", dap.repl.open, "Open REPL")
      map("<leader>dR", dap.run_last, "Run Last")
      map("<leader>dq", dap.terminate, "Terminate")
      map("<leader>dc", dap.clear_breakpoints, "Clear All Breakpoints")
      map("<leader>du", dapui.toggle, "Toggle DAP UI")
      map("<leader>de", function()
        dapui.eval(nil, { enter = true })
      end, "Evaluate Expression")

      vim.keymap.set("v", "<leader>de", function()
        dapui.eval()
      end, { desc = "DAP: Evaluate Selection" })
    end,
  },
}
