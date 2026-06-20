-- lua/mohsen/plugins/dap.lua
-- ══════════════════════════════════════════════════════════════
--  Debug Adapter Protocol — Go (Delve) + C# / .NET (netcoredbg)
--
--  کلیدهای عمومی:
--    F5  ادامه/شروع   F9  breakpoint   F10 step over
--    F11 step into    S-F11 step out
--    <leader>d…  دستورات بیشتر (REPL، terminate، UI، …)
--
--  Go:  <leader>Go دیباگ تست، <leader>GL دیباگ آخرین تست
--  C#:  <leader>Co ادامه،     <leader>Cb breakpoint
--
--  پیش‌نیاز:
--    Go → delve (mason)        C# → netcoredbg (mason) + dotnet build
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
      local mason = vim.fn.stdpath("data") .. "/mason/bin/"

      -- ────────────────────────────────────────────────────────
      -- آیکن‌ها و رنگ نشانه‌های breakpoint
      -- ────────────────────────────────────────────────────────
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticError", linehl = "", numhl = "" })

      -- ────────────────────────────────────────────────────────
      -- helper: پیدا کردن dll اجرایی پروژه (نه تست)
      -- با مدل coroutine ای nvim-dap سازگار است: اگر چند کاندید بود،
      -- اجرای دیباگ را موقتاً نگه می‌دارد تا کاربر انتخاب کند.
      -- ────────────────────────────────────────────────────────
      local function find_dll()
        local cwd = vim.fn.getcwd()
        local all = vim.fn.glob(cwd .. "/**/bin/Debug/**/*.dll", true, true)

        local function valid(f)
          return f:match("%.dll$")
            and not f:match("%.resources%.dll$")
            and not f:match("/ref/")
            and not f:match("/refint/")
            and not f:match("/%._") -- فایل‌های مخفی macOS
        end

        -- خروجی اصلی پروژه‌ها (نه تست) را جمع می‌کنیم
        local candidates = {}
        for _, f in ipairs(all) do
          if valid(f) and not f:match("%.Tests?%.dll$") then
            local name = f:match("([^/]+)%.dll$")
            if f:match("/" .. name .. "/bin/") then
              table.insert(candidates, 1, f) -- خروجی اصلی پروژه → ابتدای لیست
            else
              table.insert(candidates, f)
            end
          end
        end

        if #candidates == 0 then
          vim.notify("هیچ dll اجرایی پیدا نشد. اول: dotnet build", vim.log.levels.WARN)
          return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
        end
        if #candidates == 1 then
          return candidates[1]
        end

        -- چند کاندید → از داخل coroutine با vim.ui.select انتخاب می‌کنیم
        local co = coroutine.running()
        if co then
          vim.ui.select(candidates, {
            prompt = "کدام پروژه را دیباگ کنم؟",
            format_item = function(f)
              return f:match("([^/]+)%.dll$") .. "   (" .. f:gsub(cwd .. "/", "") .. ")"
            end,
          }, function(choice)
            coroutine.resume(co, choice or candidates[1])
          end)
          return coroutine.yield()
        end

        -- fallback اگر coroutine نبود
        return candidates[1]
      end

      -- ══════════════════════════════════════════════════════════
      -- Go / Delve
      -- ══════════════════════════════════════════════════════════
      require("dap-go").setup({
        delve = {
          path = mason .. "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
          detached = false, -- سازگار با WSL/Mac
        },
        dap_configurations = {
          { type = "go", name = "Debug Current File", request = "launch", program = "${file}" },
          { type = "go", name = "Debug Package", request = "launch", program = "${workspaceFolder}" },
          {
            type = "go",
            name = "Debug Test",
            request = "launch",
            mode = "test",
            program = "${file}",
            buildFlags = "-cover",
          },
          {
            type = "go",
            name = "Debug with Args",
            request = "launch",
            program = "${workspaceFolder}",
            args = function()
              return vim.split(vim.fn.input("Args: "), " ")
            end,
          },
          { type = "go", name = "Attach Remote", mode = "remote", request = "attach" },
        },
      })

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
      -- ══════════════════════════════════════════════════════════
      -- Python (debugpy)
      -- ══════════════════════════════════════════════════════════
      local debugpy_python = vim.fn.stdpath("data")
        .. "/mason/packages/debugpy/venv/bin/python"
      if vim.fn.has("win32") == 1 then
        debugpy_python = vim.fn.stdpath("data")
          .. "/mason/packages/debugpy/venv/Scripts/python.exe"
      end
      local ok_dappy = pcall(require, "dap-python")
      if ok_dappy then
        require("dap-python").setup(debugpy_python)
        require("dap-python").test_runner = "pytest"
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "python",
          callback = function()
            local dp = require("dap-python")
            vim.keymap.set("n", "<leader>Pm", function() dp.test_method() end,
              { desc = "Python DAP: Debug Method", buffer = true })
            vim.keymap.set("n", "<leader>Pc", function() dp.test_class() end,
              { desc = "Python DAP: Debug Class", buffer = true })
          end,
        })
      end

      -- ══════════════════════════════════════════════════════════
      -- C# / .NET  (netcoredbg)
      -- ══════════════════════════════════════════════════════════
      dap.adapters.coreclr = {
        type = "executable",
        command = mason .. "netcoredbg",
        args = { "--interpreter=vscode" },
      }
      -- razor/blazor و فایل‌های دیگر هم همان adapter
      dap.adapters.netcoredbg = dap.adapters.coreclr

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch: Console / .NET App",
          request = "launch",
          program = find_dll,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          console = "integratedTerminal",
          env = { DOTNET_ENVIRONMENT = "Development" },
        },
        {
          type = "coreclr",
          name = "Launch: ASP.NET Core",
          request = "launch",
          program = find_dll,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          console = "integratedTerminal",
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
            ASPNETCORE_URLS = "http://localhost:5000",
          },
        },
        {
          type = "coreclr",
          name = "Attach: .NET Process",
          request = "attach",
          processId = function()
            local handle = io.popen("pgrep -la dotnet 2>/dev/null")
            local out = handle and handle:read("*a") or ""
            if handle then
              handle:close()
            end
            if out ~= "" then
              vim.notify("پروسه‌های dotnet در حال اجرا:\n" .. out, vim.log.levels.INFO)
            end
            return vim.fn.input("Process ID: ")
          end,
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        callback = function()
          vim.keymap.set("n", "<leader>Co", dap.continue, { desc = "C# DAP: Continue", buffer = true })
          vim.keymap.set(
            "n",
            "<leader>Cb",
            dap.toggle_breakpoint,
            { desc = "C# DAP: Toggle Breakpoint", buffer = true }
          )
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

      -- باز/بسته شدن خودکار UI
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
      -- Keymaps عمومی
      -- ══════════════════════════════════════════════════════════
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { desc = "DAP: " .. desc })
      end

      map("<F5>", dap.continue, "Continue / Start")
      map("<F10>", dap.step_over, "Step Over")
      map("<F11>", dap.step_into, "Step Into")
      map("<S-F11>", dap.step_out, "Step Out")
      map("<F9>", dap.toggle_breakpoint, "Toggle Breakpoint")

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
