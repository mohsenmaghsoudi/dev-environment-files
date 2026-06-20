-- lua/mohsen/plugins/python.lua
-- ══════════════════════════════════════════════════════════════
--  Python IDE  (هم‌سطح Go و C#)
--
--  تقسیم مسئولیت‌ها:
--    • LSP / autocomplete / hover / type-check → pyright (after/lsp/pyright.lua)
--    • lint + format                           → ruff   (LSP + conform)
--    • تست                                     → neotest-python (<leader>T…)
--                                                + pytest مستقیم (<leader>Pt/Pa/Pn)
--    • دیباگ                                   → nvim-dap-python (dap.lua)
--    • venv selector + اجرا/REPL               → همین فایل (<leader>P…)
--
--  همه‌ی keymap های دستوری زیر پیشوند <leader>P هستند.
-- ══════════════════════════════════════════════════════════════
return {
  -- انتخاب‌گر محیط مجازی (venv) — تا pyright/debugpy/pytest پکیج‌ها را پیدا کنند
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap-python",
    },
    ft = "python",
    opts = {
      dap_enabled = true, -- venv انتخاب‌شده به دیباگ هم وصل شود
    },
    keys = {
      { "<leader>Pv", "<cmd>VenvSelect<cr>", desc = "Python: Select venv" },
    },
  },

  -- keymaps + features مخصوص فایل‌های پایتون
  {
    "neovim/nvim-lspconfig",
    ft = "python",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = "python",
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(keys, cmd, desc)
            vim.keymap.set("n", keys, cmd, { desc = "Python: " .. desc, buffer = bufnr })
          end

          -- ── اجرا و REPL ──
          map("<leader>Pr", function()
            vim.cmd("write")
            vim.cmd("botright split | resize 15")
            vim.cmd("terminal python3 " .. vim.fn.shellescape(vim.fn.expand("%")))
            vim.cmd("startinsert")
          end, "Run File")

          map("<leader>Pi", function()
            vim.cmd("botright split | resize 15 | terminal python3")
            vim.cmd("startinsert")
          end, "Open REPL")

          -- ── imports / fix (ruff) ──
          map("<leader>Po", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" } },
              apply   = true,
            })
          end, "Organize Imports")

          map("<leader>Pf", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.fixAll" } },
              apply   = true,
            })
          end, "Fix All (ruff)")

          -- ── تست با pytest مستقیم (مطمئن، مستقل از neotest) ──
          -- از python محیط فعال (venv) استفاده می‌کند.
          local function run_pytest(args)
            vim.cmd("write")
            vim.cmd("botright split | resize 15")
            vim.cmd("terminal python -m pytest " .. args)
            vim.cmd("startinsert")
          end

          map("<leader>Pt", function()
            run_pytest("-v " .. vim.fn.shellescape(vim.fn.expand("%")))
          end, "Pytest: File")

          map("<leader>Pa", function()
            run_pytest("-v")
          end, "Pytest: All")

          map("<leader>Pn", function()
            local line = vim.fn.search("def \\(test_\\w*\\)", "bcnW")
            local name = vim.fn.expand("<cword>")
            if line > 0 then
              local text = vim.fn.getline(line)
              name = text:match("def%s+([%w_]+)") or name
            end
            run_pytest("-v -k " .. vim.fn.shellescape(name))
          end, "Pytest: Nearest")
        end,
      })
    end,
  },
}
