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
        "eslint_d",
        "ruff",
        "debugpy",  -- دیباگ پایتون
        -- Go
        "delve",
        "golangci-lint",
        "gofumpt",
        "goimports",
        "gomodifytags", -- GoAddTag / GoRmTag
        "impl",         -- GoImpl
        "gotests",      -- تولید جدول تست
        "iferr",        -- GoIfErr
        -- C#
        "netcoredbg", -- debugger
        -- "csharpier",   -- formatter
        "csharpier", --formatter
      },
    },
    dependencies = { "williamboman/mason.nvim" },
  },
}
