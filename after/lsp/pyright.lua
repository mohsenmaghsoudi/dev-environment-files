-- after/lsp/pyright.lua
-- ══════════════════════════════════════════════════════════════
--  تنظیمات pyright برای پایتون.
--  ruff مسئول lint/format است؛ pyright فقط type-check و ناوبری.
--  inlay hints عمداً تنظیم نشده (pyright پشتیبانی خوبی ندارد).
-- ══════════════════════════════════════════════════════════════
return {
  settings = {
    pyright = {
      disableOrganizeImports = true, -- این کار را ruff انجام می‌دهد
    },
    python = {
      analysis = {
        typeCheckingMode       = "basic", -- basic | strict | off
        autoSearchPaths        = true,
        useLibraryCodeForTypes = true,
        autoImportCompletions  = true,
        diagnosticMode         = "openFilesOnly",
      },
    },
  },
}
