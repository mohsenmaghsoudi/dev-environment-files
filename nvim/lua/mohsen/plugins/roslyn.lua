-- lua/mohsen/plugins/roslyn.lua
-- ══════════════════════════════════════════════════════════════
--  Roslyn LSP برای C# / .NET
--  بهتر از omnisharp: همان engine که VS و VS Code استفاده می‌کنند
--
--  پیش‌نیاز نصب:
--    1. dotnet SDK نصب باشه: dotnet --version
--    2. داخل Neovim: :RoslynInstall
-- ══════════════════════════════════════════════════════════════
return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities  = cmp_nvim_lsp.default_capabilities()

      require("roslyn").setup({
        capabilities = capabilities,

        -- ────────────────────────────────
        -- تنظیمات اصلی
        -- ────────────────────────────────
        config = {
          settings = {
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_implicit_variable_types    = true,
              csharp_enable_inlay_hints_for_implicit_object_creation   = true,
              csharp_enable_inlay_hints_for_lambda_parameter_types     = true,
              csharp_enable_inlay_hints_for_types                      = true,
              dotnet_enable_inlay_hints_for_indexer_parameters         = true,
              dotnet_enable_inlay_hints_for_object_creation_parameters = true,
              dotnet_enable_inlay_hints_for_other_parameters           = true,
              dotnet_enable_inlay_hints_for_parameters                 = true,
              dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix   = true,
              dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name     = true,
              dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent     = true,
            },
            ["csharp|code_lens"] = {
              dotnet_enable_references_code_lens = true,
              dotnet_enable_tests_code_lens      = true,
            },
            ["csharp|completion"] = {
              dotnet_provide_regex_completions             = true,
              dotnet_show_completion_items_from_unimported_namespaces = true,
              dotnet_show_name_completion_suggestions      = true,
            },
            ["csharp|highlighting"] = {
              dotnet_highlight_related_json_components = true,
              dotnet_highlight_related_regex_components = true,
            },
            ["csharp|diagnostics"] = {
              dotnet_analyzer_diagnostics_scope = "openFiles",
              dotnet_compiler_diagnostics_scope = "fullSolution",
            },
            ["csharp|formatting"] = {
              dotnet_organize_imports_on_format = true,
            },
          },
        },

        -- ────────────────────────────────
        -- on_attach: keymaps و features
        -- ────────────────────────────────
        on_attach = function(client, bufnr)
          -- Inlay hints
          if vim.fn.has("nvim-0.10") == 1 then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          -- Code lens
          if client.supports_method("textDocument/codeLens") then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold" }, {
              buffer   = bufnr,
              callback = vim.lsp.codelens.refresh,
            })
          end

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "C#: " .. desc })
          end

          -- Toggle inlay hints  →  <leader>Ch
          map("<leader>Ch", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
              { bufnr = bufnr }
            )
          end, "Toggle Inlay Hints")

          -- Code lens  →  <leader>CL
          map("<leader>CL", vim.lsp.codelens.run, "Run Code Lens")

          -- Fix all (organize imports + diagnostics)
          map("<leader>Cf", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.fixAll" } },
              apply   = true,
            })
          end, "Fix All")

          -- Organize imports
          map("<leader>Ci", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" } },
              apply   = true,
            })
          end, "Organize Imports")

          -- Solution explorer (فقط roslyn)
          map("<leader>Cs", "<cmd>Roslyn restart<cr>", "Restart Roslyn")
        end,
      })
    end,
  },

  -- ────────────────────────────────────────────────────────────
  -- neotest-dotnet  –  اجرای تست C#
  -- ────────────────────────────────────────────────────────────
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
      "Issafalcon/neotest-dotnet",
    },
    ft = { "go", "cs" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            go_test_args   = { "-v", "-race", "-count=1", "-timeout=60s" },
            dap_go_enabled = true,
          }),
          require("neotest-dotnet")({
            dap = { adapter_name = "coreclr" },
          }),
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
