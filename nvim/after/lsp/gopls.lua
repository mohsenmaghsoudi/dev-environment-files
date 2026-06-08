-- after/lsp/gopls.lua
return {
  settings = {
    gopls = {
      analyses = {
        unusedparams   = true,
        unusedvariable = true,
        nilness        = true,
        shadow         = true,
        httpresponse   = true,
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
      codelenses = {
        gc_details         = true,
        generate           = true,
        run_govulncheck    = true,
        test               = true,
        tidy               = true,
        upgrade_dependency = true,
      },
    },
  },
}
