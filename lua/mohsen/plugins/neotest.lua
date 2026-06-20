-- lua/mohsen/plugins/neotest.lua
-- ══════════════════════════════════════════════════════════════
--  Neotest — Go، C# و Python
--
--  C#: از neotest-vstest (nsidorenco) استفاده می‌کنیم نه neotest-dotnet
--  قدیمیِ Issafalcon. آن adapter دیگر فعال نگهداری نمی‌شود و باگ
--  "Cannot call a sync function from non-async context" را داشت.
--  neotest-vstest با vstest کار می‌کند و آسنکرون‌سازی درست دارد.
--
--  Go: همان neotest-golang.
-- ══════════════════════════════════════════════════════════════
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
      "Nsidorenco/neotest-vstest",
      "nvim-neotest/neotest-python",
    },
    ft = { "go", "cs", "python" },
    config = function()
      -- تنظیمات neotest-vstest باید قبل از require ست شود
      vim.g.neotest_vstest = {
        dap_settings = { type = "netcoredbg" },
      }

      -- adapter ها را با pcall ایزوله می‌سازیم تا اگر یکی خطا داد،
      -- بقیه (Go و C#) سالم بمانند.
      local adapters = {}
      local ok_go, go_a = pcall(function()
        return require("neotest-golang")({
          go_test_args   = { "-v", "-race", "-count=1", "-timeout=60s" },
          dap_go_enabled = true,
        })
      end)
      if ok_go then table.insert(adapters, go_a) end

      local ok_cs, cs_a = pcall(require, "neotest-vstest")
      if ok_cs then table.insert(adapters, cs_a) end

      local ok_py, py_a = pcall(function()
        return require("neotest-python")({
          runner = "pytest",
          dap = { justMyCode = false },
        })
      end)
      if ok_py then table.insert(adapters, py_a) end

      require("neotest").setup({
        adapters = adapters,
        output  = { enabled = true, open_on_run = "short" },
        summary = { enabled = true, animated = true, follow = true, expand_errors = true },
        status  = { enabled = true, signs = true, virtual_text = true },
      })

      local map = function(k, f, d)
        vim.keymap.set("n", k, f, { desc = "Test: " .. d })
      end

      map("<leader>Tt", function() require("neotest").run.run() end,                     "Run Nearest")
      map("<leader>TT", function() require("neotest").run.run(vim.fn.expand("%")) end,    "Run File")
      map("<leader>Ta", function() require("neotest").run.run(vim.fn.getcwd()) end,       "Run All")
      map("<leader>Ts", function() require("neotest").summary.toggle() end,              "Toggle Summary")
      map("<leader>To", function() require("neotest").output.open({ enter = true }) end, "Show Output")
      map("<leader>TO", function() require("neotest").output_panel.toggle() end,         "Toggle Output Panel")
      map("<leader>TS", function() require("neotest").run.stop() end,                    "Stop")
      map("<leader>Td", function()
        require("neotest").run.run({ strategy = "dap" })
      end, "Debug Nearest")
    end,
  },
}
