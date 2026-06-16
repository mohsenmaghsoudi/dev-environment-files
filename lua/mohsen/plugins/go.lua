-- lua/mohsen/plugins/go.lua
-- ══════════════════════════════════════════════════════════════
--  Go IDE — go.nvim (روی gopls که در after/lsp/gopls.lua تنظیم شده)
--
--  تقسیم مسئولیت‌ها (تا تداخل نباشد):
--    • LSP / autocomplete / hover / rename → gopls   (after/lsp/gopls.lua)
--    • فرمت (goimports + gofumpt)           → conform (formatting.lua)
--    • lint (golangci-lint)                 → nvim-lint (linting.lua) و <leader>Gl
--    • تست                                  → neotest (neotest.lua, <leader>T…)
--    • دیباگ (delve)                        → nvim-dap (dap.lua)
--    • دستورهای کمکی (iferr, fillstruct,…)  → go.nvim (همین فایل)
--
--  همه‌ی keymap های دستوری زیر پیشوند <leader>G هستند.
-- ══════════════════════════════════════════════════════════════
return {
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "nvim-treesitter/nvim-treesitter" },
    ft    = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
      require("go").setup({
        -- gopls را خودمان (در after/lsp/gopls.lua) مدیریت می‌کنیم
        lsp_cfg       = false,
        lsp_gofumpt   = true,
        lsp_on_attach = false,
        -- فرمت و dap را go.nvim دست نزند (conform و nvim-dap مسئول‌اند)
        lsp_keymaps   = false,
        dap_debug     = false,
        luasnip       = true,
        -- تگ‌ها
        tag_transform = "camelcase",
        tag_options   = "json=omitempty",
        -- اجرای دستورهای خروجی در یک ترمینال شناور تمیز
        run_in_floaterm = false,
        diagnostic = {
          hdlr             = false, -- بگذار gopls/native هندل کند، نه go.nvim
          underline        = true,
          virtual_text     = { space = 1 },
          signs            = true,
          update_in_insert = false,
        },
      })

      -- ────────────────────────────────────────────────────────
      -- keymaps + features مخصوص فایل‌های Go
      -- ────────────────────────────────────────────────────────
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "go", "gomod", "gowork", "gotmpl" },
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(keys, cmd, desc)
            vim.keymap.set("n", keys, cmd, { desc = "Go: " .. desc, buffer = bufnr })
          end

          -- inlay hints روشن به‌صورت پیش‌فرض (مثل C#)
          pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })

          -- ── اجرا / ساخت ──
          map("<leader>Gr", "<cmd>GoRun<cr>",   "Run")
          map("<leader>Gb", "<cmd>GoBuild<cr>", "Build")
          map("<leader>Gv", "<cmd>GoVet<cr>",   "Vet")
          map("<leader>Gg", "<cmd>GoGenerate<cr>", "Generate")

          -- ── تست ──
          map("<leader>Gt", "<cmd>GoTest<cr>",          "Test Package")
          map("<leader>GT", "<cmd>GoTestFunc<cr>",      "Test Function")
          map("<leader>Gc", "<cmd>GoCoverage<cr>",      "Coverage")
          map("<leader>GC", "<cmd>GoCoverageClear<cr>", "Coverage Clear")
          map("<leader>Ga", "<cmd>GoAlt<cr>",           "Alternate (file↔test)")

          -- ── کد ──
          map("<leader>Gf", "<cmd>GoFillStruct<cr>", "Fill Struct")
          map("<leader>Ge", "<cmd>GoIfErr<cr>",      "Add if err")
          map("<leader>GI", "<cmd>GoImpl<cr>",       "Implement Interface")

          -- ── Import / Module / Tag ──
          map("<leader>Gi", "<cmd>GoImports<cr>",      "Imports")
          map("<leader>Gm", "<cmd>GoModTidy<cr>",      "go mod tidy")
          map("<leader>Gaj", "<cmd>GoAddTag json<cr>", "Add JSON Tag")
          map("<leader>Gad", "<cmd>GoAddTag db<cr>",   "Add DB Tag")
          map("<leader>Grt", "<cmd>GoRmTag<cr>",       "Remove Tag")

          -- ── Lint / Doc ──
          map("<leader>Gl", "<cmd>GoLint<cr>", "Lint (golangci-lint)")
          map("<leader>Gd", "<cmd>GoDoc<cr>",  "Doc")

          -- ── Inlay Hints toggle ──
          map("<leader>Gh", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
              { bufnr = bufnr }
            )
          end, "Toggle Inlay Hints")

          -- ── Code Lens ──
          map("<leader>GR", vim.lsp.codelens.run, "Run Code Lens")
        end,
      })
    end,
  },
}
