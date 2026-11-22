-- return {
--   "nvim-treesitter/nvim-treesitter",
--   event = { "BufReadPre", "BufNewFile" },
--   build = ":TSUpdate",
--   dependencies = {
--     "windwp/nvim-ts-autotag",
--   },
--   config = function()
--     require("nvim-treesitter").setup()
--
--     vim.treesitter.language.register("go", "go")
--
--     -- ensure_installed
--     local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
--     _ = parser_config -- suppress unused warning
--
--     require("nvim-treesitter.install").ensure_installed({
--       "json", "javascript", "typescript", "tsx", "yaml",
--       "html", "css", "prisma", "markdown", "markdown_inline",
--       "svelte", "graphql", "bash", "lua", "vim", "dockerfile",
--       "gitignore", "query", "vimdoc", "c", "python",
--       "go", "gomod", "gosum", "c_sharp",
--     })
--
--     -- autotag
--     require("nvim-ts-autotag").setup({
--       opts = {
--         enable_close       = true,
--         enable_rename      = true,
--         enable_close_on_slash = true,
--       },
--     })
--
--     -- incremental selection
--     vim.keymap.set("n", "<C-space>", function()
--       vim.cmd("normal! viw")
--     end, { desc = "Start selection" })
--   end,
-- }
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- این پلاگین از lazy-load پشتیبانی نمی‌کند
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		require("nvim-treesitter").setup()

		-- نصب پارسرها (async است و پارسرهای نصب‌شده را رد می‌کند)
		require("nvim-treesitter").install({
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"prisma",
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
		})

		-- فعال‌سازی هایلایت و ایندنت برای هر فایل
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local ok = pcall(vim.treesitter.start, args.buf)
				if ok then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- autotag
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		})

		-- incremental selection (Neovim 0.12+ بصورت پیش‌فرض: van / vin)
		vim.keymap.set("n", "<C-space>", function()
			vim.cmd("normal! viw")
		end, { desc = "Start selection" })
	end,
}
