return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  enabled = true, -- پیش‌فرض غیرفعال، Copilot فعاله
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<C-y>", -- همون کلید Copilot
        clear_suggestion = "<C-e>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { "TelescopePrompt", "NvimTree" },
      color = {
        suggestion_color = "#808080",
      },
    })
  end,
}
