return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
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
        "helm_ls",
        "bashls",
        "ansiblels",
        "yamlls",
        "dockerls",
        -- roslyn از mason-lspconfig نیست، با :RoslynInstall نصب می‌شه
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
        "prettier",
        "stylua",
        "isort",
        "black",
        "flake8",
        "eslint_d",
        "ruff",
        -- Go
        "delve",
        "golangci-lint",
        "gofumpt",
        "goimports",
        -- C#
        "netcoredbg", -- debugger
        -- "csharpier",   -- formatter
        "csharpier", --formatter
      },
    },
    dependencies = { "williamboman/mason.nvim" },
  },
}
