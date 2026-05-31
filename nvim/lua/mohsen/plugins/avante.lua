return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  opts = {
    provider = "openai",
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        extra_request_body = {
          temperature = 0.7,
          max_tokens = 8192,
        },
      },
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-5", -- ✅ اصلاح شد
        extra_request_body = {
          temperature = 0.7,
          max_tokens = 8192,
        },
      },
    },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-tree/nvim-web-devicons",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "Avante" },
      opts = { file_types = { "markdown", "Avante" } },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "💬 چت با AI" },
    {
      "<leader>at",
      function()
        local current = require("avante.config").provider
        local next_provider = current == "openai" and "claude" or "openai"
        require("avante.config").override({ provider = next_provider })
        vim.notify("Provider: " .. next_provider, vim.log.levels.INFO)
      end,
      desc = "🔄 سوئیچ بین GPT و Claude",
    },
    { "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "✏️ ویرایش با AI", mode = { "n", "v" } },
    { "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "🔄 رفرش پاسخ" },
    { "<leader>af", "<cmd>AvanteFocus<CR>", desc = "🎯 فوکوس روی پنل" },
    { "<leader>ac", "<cmd>AvanteClear<CR>", desc = "🗑️ پاک کردن چت" }, -- ✅ اصلاح شد
    {
      "<leader>ag",
      function()
        require("avante.config").override({ provider = "openai" })
        vim.cmd("AvanteAsk")
      end,
      desc = "🤖 چت با GPT-4o",
    },
    {
      "<leader>al",
      function()
        require("avante.config").override({ provider = "claude" })
        vim.cmd("AvanteAsk")
      end,
      desc = "🧠 چت با Claude",
    },
  },
}
