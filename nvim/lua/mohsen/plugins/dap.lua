return {
  -- Core DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "williamboman/mason.nvim", -- برای نصب netcoredbg
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- ──────────────────────────────────────────────
      -- netcoredbg adapter (نصب از طریق Mason)
      -- ──────────────────────────────────────────────
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
        args = { "--interpreter=vscode" },
      }

      -- alias برای اینکه هر دو نام کار کنند
      dap.adapters.netcoredbg = dap.adapters.coreclr

      -- ──────────────────────────────────────────────
      -- تنظیمات برای C#
      -- ──────────────────────────────────────────────
      dap.configurations.cs = {
        -- حالت Launch: اجرا و دیباگ مستقیم
        {
          type = "coreclr",
          name = "Launch: .NET",
          request = "launch",
          program = function()
            -- جستجوی خودکار فایل dll
            local cwd = vim.fn.getcwd()
            local result = vim.fn.glob(cwd .. "/**/bin/Debug/**/*.dll", true, true)

            -- فیلتر کردن فایل‌های غیر مرتبط
            result = vim.tbl_filter(function(f)
              return not f:match("%.resources%.dll$") and not f:match("ref/")
            end, result)

            if #result == 1 then
              return result[1]
            elseif #result > 1 then
              -- انتخاب دستی اگر چند dll پیدا شد
              return vim.fn.input("Path to dll: ", result[1], "file")
            else
              return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
            end
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
          },
        },
        -- حالت Attach: اتصال به پروسه در حال اجرا
        {
          type = "coreclr",
          name = "Attach: .NET Process",
          request = "attach",
          processId = function()
            -- لیست پروسه‌های dotnet
            local handle = io.popen("pgrep -a dotnet 2>/dev/null || ps aux | grep dotnet | grep -v grep")
            local result = handle and handle:read("*a") or ""
            if handle then
              handle:close()
            end

            print(result)
            return vim.fn.input("Process ID: ")
          end,
        },
        -- حالت Launch برای ASP.NET Core
        {
          type = "coreclr",
          name = "Launch: ASP.NET Core",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            local result = vim.fn.glob(cwd .. "/**/bin/Debug/**/*.dll", true, true)
            result = vim.tbl_filter(function(f)
              return not f:match("%.resources%.dll$") and not f:match("ref/")
            end, result)
            if #result >= 1 then
              return result[1]
            end
            return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          console = "integratedTerminal", -- ← این رو اضافه کن
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
            ASPNETCORE_URLS = "http://localhost:5000",
          },
          args = {},
        },
      }

      -- ──────────────────────────────────────────────
      -- DAP UI تنظیمات
      -- ──────────────────────────────────────────────
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
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
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks", size = 0.30 },
              { id = "watches", size = 0.20 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = { close = { "q", "<Esc>" } },
        },
      })

      -- ──────────────────────────────────────────────
      -- باز/بسته شدن خودکار UI
      -- ──────────────────────────────────────────────
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- ──────────────────────────────────────────────
      -- Virtual Text (نمایش مقدار متغیرها کنار کد)
      -- ──────────────────────────────────────────────
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = "eol",
      })

      -- ──────────────────────────────────────────────
      -- Keymaps
      -- ──────────────────────────────────────────────
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { desc = "DAP: " .. desc })
      end

      -- اجرا و کنترل
      map("<F5>", dap.continue, "Continue / Start")
      map("<F10>", dap.step_over, "Step Over")
      map("<F11>", dap.step_into, "Step Into")
      map("<S-F11>", dap.step_out, "Step Out")
      map("<F9>", dap.toggle_breakpoint, "Toggle Breakpoint")

      -- Breakpoint پیشرفته
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "Conditional Breakpoint")

      map("<leader>dl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
      end, "Log Breakpoint")

      -- کنترل session
      map("<leader>dr", dap.repl.open, "Open REPL")
      map("<leader>dR", dap.run_last, "Run Last")
      map("<leader>dq", dap.terminate, "Terminate")
      map("<leader>dc", dap.clear_breakpoints, "Clear All Breakpoints")

      -- UI
      map("<leader>du", dapui.toggle, "Toggle UI")
      map("<leader>de", function()
        dapui.eval(nil, { enter = true })
      end, "Evaluate Expression")

      -- Visual mode: ارزیابی انتخاب
      vim.keymap.set("v", "<leader>de", function()
        dapui.eval()
      end, { desc = "DAP: Evaluate Selection" })
    end,
  },
}
