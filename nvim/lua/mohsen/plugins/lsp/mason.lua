return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      -- list of servers for mason to install
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "ruff",
        "gopls",
        "jsonls",
        "hydra_lsp",
        "helm_ls",
        "bashls",
        "ansiblels",
        "omnisharp",
        "yamlls",
        "dockerls",
      },
    },
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        --        "pylint", -- python linter
        "flake8",
        "eslint_d", -- js linter
        "csharpier",
        "ruff",
        "netcoredbg", -- .NET debugger
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
}
