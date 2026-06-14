return {
  -- 🔹 Codeium: autocomplete رایگان
  {
    "Exafunction/codeium.nvim",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({})
    end,
  },

  -- 🔹 ChatGPT.nvim: چت و ویرایش هوشمند کد
  --   {
  --     "jackMort/ChatGPT.nvim",
  --     event = "VeryLazy",
  --     cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions", "ChatGPTRun" },
  --     dependencies = {
  --       "MunifTanjim/nui.nvim",
  --       "nvim-lua/plenary.nvim",
  --       "nvim-telescope/telescope.nvim",
  --     },
  --     config = function()
  --       require("chatgpt").setup({})
  --
  --       -- 🔑 فقط بعد از لود شدن پلاگین، keymapها رو ست کن
  --       local keymap = vim.keymap
  --       keymap.set("n", "<leader>cc", "<cmd>ChatGPT<CR>", { desc = "ChatGPT window" })
  --       keymap.set("v", "<leader>ce", ":ChatGPTRun explain_code<CR>", { desc = "Explain code" })
  --       keymap.set("v", "<leader>cr", ":ChatGPTEditWithInstructions<CR>", { desc = "Edit with instructions" })
  --     end,
  --   },
}
