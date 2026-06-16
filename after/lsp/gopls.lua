-- after/lsp/gopls.lua
-- ══════════════════════════════════════════════════════════════
--  تنظیمات سرور gopls (با vim.lsp.config مرج می‌شود)
--  capabilities سراسری از plugins/lsp/lsp.lua می‌آید.
-- ══════════════════════════════════════════════════════════════
return {
  settings = {
    gopls = {
      -- ── آنالیزها (staticcheck + موارد مفید اضافه) ──
      analyses = {
        unusedparams      = true,
        unusedvariable    = true,
        nilness           = true,
        shadow            = true,
        httpresponse      = true,
        unusedwrite       = true,
        useany            = true,
        fieldalignment    = false, -- پر سر و صداست؛ در صورت نیاز روشن کن
      },
      staticcheck = true,

      -- ── inlay hints (با <leader>Gh قابل toggle) ──
      hints = {
        assignVariableTypes    = true,
        compositeLiteralFields = true,
        compositeLiteralTypes  = true,
        constantValues         = true,
        functionTypeParameters = true,
        parameterNames         = true,
        rangeVariableTypes     = true,
      },

      -- ── تکمیل و hover ──
      completeUnimported = true,   -- پکیج‌های import‌نشده هم در autocomplete
      usePlaceholders    = true,   -- پر کردن پارامترها هنگام تکمیل تابع
      gofumpt            = true,    -- سبک سخت‌گیرانه‌تر فرمت
      semanticTokens     = true,
      hoverKind          = "FullDocumentation",
      completionDocumentation = true,

      -- گروه‌بندی import های داخلی پروژه:
      -- prefix را با مسیر ماژول پروژه‌ات (همان خط module در go.mod) عوض کن
      -- ["local"] = "github.com/you/yourmodule",

      -- ── امنیت و کارایی ──
      vulncheck        = "Imports",
      directoryFilters = { "-.git", "-node_modules", "-vendor", "-bin" },

      -- ── code lens ها (run/test/tidy/… بالای کد) ──
      codelenses = {
        gc_details         = true,
        generate           = true,
        run_govulncheck    = true,
        test               = true,
        tidy               = true,
        upgrade_dependency = true,
        regenerate_cgo     = true,
      },
    },
  },
}
