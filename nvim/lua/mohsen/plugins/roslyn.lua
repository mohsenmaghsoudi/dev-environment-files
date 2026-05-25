return {
  "seblyng/roslyn.nvim",
  branch = "main", -- یا "stable" اگر می‌خوای
  ft = { "cs", "vb", "csproj", "sln" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "williamboman/mason.nvim",
  },
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    require("roslyn").setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- keymapهای دلخواهت رو اینجا بذار یا از core/keymaps.lua فراخوانی کن
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      end,
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
        },
      },
    })
  end,
}
