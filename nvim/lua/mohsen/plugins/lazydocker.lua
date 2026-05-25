return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    direction = "float",
    float_opts = {
      border = "curved",
    },
  },
  keys = {
    { "<leader>ld", desc = "Open lazydocker" },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal
    local lazydocker = Terminal:new({
      cmd = "lazydocker",
      hidden = true,
      direction = "float",
      float_opts = {
        border = "double",
      },
    })

    vim.keymap.set("n", "<leader>ld", function()
      lazydocker:toggle()
    end, { desc = "Open lazydocker" })
  end,
  cmd = { "ToggleTerm", "TermExec" },
}
