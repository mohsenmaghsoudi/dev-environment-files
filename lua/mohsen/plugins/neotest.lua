-- lua/mohsen/plugins/neotest.lua
-- ══════════════════════════════════════════════════════════════
--  Neotest: Go, C# and Python
--
--  C#:     neotest-vstest (not the old neotest-dotnet). It is configured
--          through vim.g.neotest_vstest, which must be set before require.
--  Go:     neotest-golang (debugging via dap-go; delve options from dap_util)
--  Python: neotest-python (uses venv-selector or the project venv)
--
--  Debug a test: <leader>Td (uses the same adapters and nvim-dap)
-- ══════════════════════════════════════════════════════════════
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
      "fredrikaverpil/neotest-golang",
      "Nsidorenco/neotest-vstest",
      "nvim-neotest/neotest-python",
    },
    -- Loads both when a file of these languages is opened (for the pass/fail
    -- signs) and when a key is pressed (so the keys work from any file).
    ft = { "go", "cs", "python" },
    keys = {
      { "<leader>Tt", function() require("neotest").run.run() end, desc = "Test: Run Nearest" },
      { "<leader>TT", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: Run File" },
      { "<leader>Ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Test: Run All" },
      { "<leader>Tl", function() require("neotest").run.run_last() end, desc = "Test: Run Last" },
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: Debug Nearest" },
      { "<leader>TS", function() require("neotest").run.stop() end, desc = "Test: Stop" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Test: Toggle Summary" },
      { "<leader>To", function() require("neotest").output.open({ enter = true }) end, desc = "Test: Show Output" },
      { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Test: Toggle Output Panel" },
      { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Test: Watch File" },
      { "]T", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Test: Next Failed" },
      { "[T", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Test: Prev Failed" },
    },
    config = function()
      local util = require("mohsen.dap_util")

      -- C#: must be set before require("neotest-vstest")
      vim.g.neotest_vstest = {
        -- netcoredbg, using the adapter defined in dap.lua
        dap_settings = { type = "netcoredbg", justMyCode = false },
      }

      -- Each adapter is built separately so one failure does not break the
      -- others, and errors are reported instead of swallowed.
      local adapters = {}
      local function add(name, builder)
        local ok, res = pcall(builder)
        if ok and res then
          table.insert(adapters, res)
        else
          vim.notify(name .. ": " .. tostring(res), vim.log.levels.WARN, { title = "neotest" })
        end
      end

      add("neotest-golang", function()
        return require("neotest-golang")({
          -- gotestsum gives nicer output; falls back to plain go test
          -- (install: go install gotest.tools/gotestsum@latest)
          runner = vim.fn.executable("gotestsum") == 1 and "gotestsum" or "go",
          -- -race is slow and needs CGO; add it when you need it
          go_test_args = { "-v", "-count=1", "-timeout=60s" },
          -- Debug via dap-go, with the same delve options as dap.lua
          dap_mode = "dap-go",
          dap_go_opts = function()
            return util.go_opts()
          end,
        })
      end)

      add("neotest-vstest", function()
        return require("neotest-vstest")
      end)

      add("neotest-python", function()
        return require("neotest-python")({
          runner = "pytest",
          python = util.python_for_tests,
          dap = { justMyCode = false },
        })
      end)

      require("neotest").setup({
        adapters = adapters,
        output = { enabled = true, open_on_run = "short" },
        summary = { enabled = true, animated = true, follow = true, expand_errors = true },
        status = { enabled = true, signs = true, virtual_text = true },
      })
    end,
  },
}
