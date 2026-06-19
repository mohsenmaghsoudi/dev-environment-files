-- after/lsp/basedpyright.lua  (و pyright)
-- ══════════════════════════════════════════════════════════════
--  تنظیمات pyright برای پایتون.
--  ruff مسئول lint/format است؛ pyright فقط type-check و ناوبری.
--  برای جلوگیری از تداخل، قابلیت‌های هم‌پوشان ruff خاموش می‌شوند.
-- ══════════════════════════════════════════════════════════════
return {
  settings = {
    pyright = {
      -- analysis توسط pyright؛ lint توسط ruff (تداخل نکنند)
      disableOrganizeImports = true, -- این کار را ruff انجام می‌دهد
    },
    python = {
      analysis = {
        typeCheckingMode        = "basic",  -- basic | strict | off
        autoSearchPaths         = true,
        useLibraryCodeForTypes  = true,
        autoImportCompletions   = true,
        diagnosticMode          = "openFilesOnly", -- یا "workspace"
        inlayHints = {
          variableTypes          = true,
          functionReturnTypes    = true,
          callArgumentNames      = true,
          pytestParameters       = true,
        },
      },
    },
  },
}
