local parsers = {
  "json",
  "javascript",
  "typescript",
  "tsx",
  "yaml",
  "html",
  "css",
  "markdown",
  "markdown_inline",
  "svelte",
  "graphql",
  "bash",
  "lua",
  "vim",
  "dockerfile",
  "gitignore",
  "query",
  "vimdoc",
  "c",
  "python",
  "go",
  "gomod",
  "gosum",
  "c_sharp",
}

for _, lang in ipairs(parsers) do
  local ok = pcall(vim.treesitter.language.inspect, lang)
  if not ok then
    vim.notify("Installing treesitter parser: " .. lang, vim.log.levels.INFO)
    pcall(function()
      vim.cmd("TSInstall " .. lang)
    end)
  end
end

-- highlight
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(ev)
    local ok = pcall(vim.treesitter.start, ev.buf)
    if not ok then
    end
  end,
})

-- indentation با treesitter
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "typescript",
    "tsx",
    "jsx",
    "lua",
    "python",
    "go",
    "c_sharp",
    "cs",
    "html",
    "css",
    "json",
    "yaml",
  },
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim.treesitter'.indentexpr()"
  end,
})

-- incremental selection
vim.keymap.set("n", "<C-space>", function()
  vim.cmd("normal! viw")
end, { desc = "Start selection" })

return {
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
}
