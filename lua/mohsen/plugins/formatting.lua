return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local conform = require("conform")

    -- csharpier نسخه 1.x: دستور CLI عوض شده و حالا «format» لازم است.
    -- نسخه‌های قدیمی conform هنوز فرم قدیمی را صدا می‌زنند که باعث
    -- timeout می‌شود. اینجا formatter را با دستور درست تعریف می‌کنیم.
    -- مسیر mason را هم مستقیم می‌دهیم تا به PATH وابسته نباشد.
    local mason_csharpier = vim.fn.stdpath("data") .. "/mason/bin/csharpier"
    conform.formatters.csharpier = {
      command = vim.fn.executable(mason_csharpier) == 1 and mason_csharpier or "csharpier",
      args = { "format", "--write-stdout" },
      stdin = true,
    }

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },

        lua = { "stylua" },

        python = { "isort", "black" },

        go = { "goimports", "gofumpt" },
        gomod = { "goimports" },
        gowork = { "goimports" },

        cs = { "csharpier" },
      },

      format_on_save = function(bufnr)
        -- برای C# تایم‌اوت بیشتر چون csharpier روی اجرای اول کند است
        local ft = vim.bo[bufnr].filetype
        local timeout = (ft == "cs") and 10000 or 3000
        return {
          lsp_format = "fallback",
          async = false,
          timeout_ms = timeout,
        }
      end,
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 10000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
