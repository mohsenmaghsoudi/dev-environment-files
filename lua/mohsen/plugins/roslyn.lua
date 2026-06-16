-- lua/mohsen/plugins/roslyn.lua
-- ══════════════════════════════════════════════════════════════
--  Roslyn LSP برای C# / .NET
--
--  نکته: vim.lsp.config("roslyn", ...) باید قبل از اینکه پلاگین
--  سرور را با vim.lsp.enable فعال کند آماده باشد، وگرنه settings
--  (از جمله inlay_hints) به سرور نمی‌رسد و هیچ hint نمایش داده نمی‌شود.
--  به همین دلیل آن را در init (نه config) و در سطح بالا صدا می‌زنیم.
--
--  پیش‌نیاز:
--    1. dotnet SDK: dotnet --version
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
    -- init زودتر از config اجرا می‌شود؛ اینجا تنظیمات سرور را ست می‌کنیم
    init = function()
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = ok and cmp_nvim_lsp.default_capabilities()
        or vim.lsp.protocol.make_client_capabilities()

      vim.lsp.config("roslyn", {
        capabilities = capabilities,
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
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name   = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent   = true,
          },
          ["csharp|code_lens"] = {
            -- references code lens در nvim ارور می‌دهد (peekReferences)؛
            -- برای references از gR استفاده کن.
            dotnet_enable_references_code_lens = false,
            dotnet_enable_tests_code_lens      = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions                        = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions                 = true,
          },
          ["csharp|highlighting"] = {
            dotnet_highlight_related_json_components  = true,
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
      })
    end,
    config = function()
      require("roslyn").setup({})

      -- هندلر برای command مخصوص VS Code که nvim بلد نیست
      vim.lsp.commands = vim.lsp.commands or {}
      vim.lsp.commands["roslyn.client.peekReferences"] = function()
        pcall(vim.cmd, "Telescope lsp_references")
      end
    end,
  },
}
