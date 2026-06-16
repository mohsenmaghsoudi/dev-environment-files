-- lua/mohsen/plugins/neotest.lua
-- ══════════════════════════════════════════════════════════════
--  Neotest — Go و C#
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
    },
    ft = { "go", "cs" },
    config = function()
      -- تنظیمات neotest-vstest باید قبل از require ست شود
      vim.g.neotest_vstest = {
        dap_settings = { type = "netcoredbg" },
      }

      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            go_test_args   = { "-v", "-race", "-count=1", "-timeout=60s" },
            dap_go_enabled = true,
          }),
          require("neotest-vstest"),
        },
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
