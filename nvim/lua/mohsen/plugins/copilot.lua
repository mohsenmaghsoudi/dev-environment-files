-- for inline,
return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = false,
        auto_trigger = true,
        keymap = {
          accept = "<C-y>",
          next = "<C-'>",
          prev = "<C-;>",
          dismiss = "<C-e>",
        },
      },
      panel = { enabled = false },
    })
  end,
}
-- for cmp without inline suggestions
-- return {
--   -- 🔹 GitHub Copilot برای cmp (بدون پیشنهاد inline)
--   {
--     "zbirenbaum/copilot-cmp",
--     dependencies = {
--       "zbirenbaum/copilot.lua",
--     },
--     config = function()
--       require("copilot_cmp").setup()
--     end,
--   },
--   {
--     "zbirenbaum/copilot.lua",
--     cmd = "Copilot",
--     event = "InsertEnter",
--     config = function()
--       require("copilot").setup({
--         suggestion = { enabled = false },
--         panel = { enabled = false },
--       })
--     end,
--   },
-- }
