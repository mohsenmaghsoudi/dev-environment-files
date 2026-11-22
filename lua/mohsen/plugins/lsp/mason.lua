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
        -- roslyn is not in mason-lspconfig; install it with :RoslynInstall
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
        "debugpy",  -- Python debugger
        -- Go
        "delve",
        "golangci-lint",
        "gofumpt",
        "goimports",
        "gomodifytags", -- GoAddTag / GoRmTag
        "impl",         -- GoImpl
        "gotests",      -- table-driven test generator
        "iferr",        -- GoIfErr
        -- C#
        -- netcoredbg is intentionally not here: Mason requests the old asset
        -- (osx-amd64.tar.gz) and gets a 404. Run in nvim:  :NetcoredbgInstall
        "csharpier", -- formatter
      },
    },
    dependencies = { "williamboman/mason.nvim" },
  },
}
