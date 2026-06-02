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

  -- سوئیچ بین Copilot و Supermaven
  vim.keymap.set("n", "<leader>cs", function()
    local copilot = require("copilot.suggestion")
    if copilot then
      vim.cmd("Copilot disable")
      require("supermaven-nvim.api").stop()
      -- بررسی کدوم فعاله
      local current = vim.g.ai_provider or "copilot"
      if current == "copilot" then
        vim.cmd("Copilot disable")
        require("supermaven-nvim.api").start()
        vim.g.ai_provider = "supermaven"
        vim.notify("🚀 Supermaven فعال شد", vim.log.levels.INFO)
      else
        require("supermaven-nvim.api").stop()
        vim.cmd("Copilot enable")
        vim.g.ai_provider = "copilot"
        vim.notify("🤖 Copilot فعال شد", vim.log.levels.INFO)
      end
    end
  end, { desc = "سوئیچ Copilot/Supermaven" }),
}
