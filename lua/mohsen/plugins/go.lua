-- lua/mohsen/plugins/go.lua
-- ══════════════════════════════════════════════════════════════
--  Keymaps انتخاب‌شده با توجه به keymap های موجود:
--    <leader>G  → همه دستورات go.nvim
--    <leader>Tt → neotest (T بزرگ برای test)
--    keymaps موجود که conflict ندارن:
--      h=gitsigns, f=telescope, x=trouble, e=nvim-tree
--      w=session, s=split, t=tab, a=avante, d=dap
--      m=format, l=lint, n=nohl
-- ══════════════════════════════════════════════════════════════
return {
  -- ────────────────────────────────────────────────────────────
  -- go.nvim
  -- ────────────────────────────────────────────────────────────
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "nvim-treesitter/nvim-treesitter" },
    ft    = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
      require("go").setup({
        lsp_cfg       = false,
        lsp_gofumpt   = true,
        lsp_on_attach = false,
        dap_debug     = false,
        luasnip       = true,
        tag_transform = "camelcase",
        tag_options   = "json=omitempty",
        diagnostic = {
          hdlr             = true,
          underline        = true,
          virtual_text     = { space = 1 },
          signs            = true,
          update_in_insert = false,
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "go", "gomod" },
        callback = function()
          local map = function(keys, cmd, desc)
            vim.keymap.set("n", keys, cmd, { desc = "Go: " .. desc, buffer = true })
          end

          -- اجرا
          map("<leader>Gr", "<cmd>GoRun<cr>",   "Run")
          map("<leader>Gb", "<cmd>GoBuild<cr>", "Build")
          map("<leader>Gv", "<cmd>GoVet<cr>",   "Vet")

          -- تست
          map("<leader>Gt", "<cmd>GoTest<cr>",          "Test All")
          map("<leader>GT", "<cmd>GoTestFunc<cr>",      "Test Function")
          map("<leader>Gc", "<cmd>GoCoverage<cr>",      "Coverage")
          map("<leader>GC", "<cmd>GoCoverageClear<cr>", "Coverage Clear")

          -- کد
          map("<leader>Gf", "<cmd>GoFillStruct<cr>", "Fill Struct")
          map("<leader>Ge", "<cmd>GoIfErr<cr>",      "Add if err")
          map("<leader>GI", "<cmd>GoImpl<cr>",       "Implement Interface")

          -- Import / Tag
          map("<leader>Gi", "<cmd>GoImports<cr>",      "Imports")
          map("<leader>Gaj", "<cmd>GoAddTag json<cr>", "Add JSON Tag")
          map("<leader>Gad", "<cmd>GoAddTag db<cr>",   "Add DB Tag")
          map("<leader>Grt", "<cmd>GoRmTag<cr>",       "Remove Tag")

          -- Lint / Doc
          map("<leader>Gl", "<cmd>GoLint<cr>", "Lint")
          map("<leader>Gd", "<cmd>GoDoc<cr>",  "Doc")

          -- Inlay Hints (toggle)
          map("<leader>Gh", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
            )
          end, "Toggle Inlay Hints")

          -- Code Lens
          map("<leader>GR", vim.lsp.codelens.run, "Run Code Lens")
        end,
      })
    end,
  },

  -- ────────────────────────────────────────────────────────────
  -- Neotest
  -- ────────────────────────────────────────────────────────────
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
    },
    ft = { "go" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            go_test_args   = { "-v", "-race", "-count=1", "-timeout=60s" },
            dap_go_enabled = true,
          }),
        },
        output  = { enabled = true, open_on_run = "short" },
        summary = { enabled = true, animated = true, follow = true, expand_errors = true },
        status  = { enabled = true, signs = true, virtual_text = true },
      })

      local map = function(k, f, d)
        vim.keymap.set("n", k, f, { desc = "Test: " .. d })
      end

      -- <leader>T برای test (T بزرگ تا با <leader>t tab conflict نداشته باشه)
      map("<leader>Tt", function() require("neotest").run.run() end,                      "Run Nearest")
      map("<leader>TT", function() require("neotest").run.run(vim.fn.expand("%")) end,     "Run File")
      map("<leader>Ta", function() require("neotest").run.run(vim.fn.getcwd()) end,        "Run All")
      map("<leader>Ts", function() require("neotest").summary.toggle() end,               "Toggle Summary")
      map("<leader>To", function() require("neotest").output.open({ enter = true }) end,  "Show Output")
      map("<leader>TO", function() require("neotest").output_panel.toggle() end,          "Toggle Output Panel")
      map("<leader>TS", function() require("neotest").run.stop() end,                     "Stop")
      map("<leader>Td", function()
        require("neotest").run.run({ strategy = "dap" })
      end, "Debug Nearest")
    end,
  },
}
