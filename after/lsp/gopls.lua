-- after/lsp/gopls.lua
return {
  settings = {
    gopls = {
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
      hints = {
        assignVariableTypes    = true,
        compositeLiteralFields = true,
        compositeLiteralTypes  = true,
        constantValues         = true,
        functionTypeParameters = true,
        parameterNames         = true,
        rangeVariableTypes     = true,
      },
      completeUnimported = true,
      usePlaceholders    = true,
      staticcheck        = true,
      gofumpt            = true,
      semanticTokens     = true,
      -- گروه‌بندی import های local؛ prefix را با ماژول پروژه‌ات عوض کن
      -- ["local"] = "your.module/path",
      vulncheck          = "Imports",
      directoryFilters   = { "-.git", "-node_modules", "-vendor" },
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
