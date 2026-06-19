-- lua/mohsen/plugins/treesitter.lua
-- ══════════════════════════════════════════════════════════════
--  nvim-treesitter — شاخه‌ی main (سازگار با Neovim 0.12)
--  شاخه‌ی master فریز شده و با 0.12 کار نمی‌کند.
--  API جدید: نصب پارسر دست خودمان، highlight/indent با autocmd.
-- ══════════════════════════════════════════════════════════════
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("nvim-treesitter").setup({})

			-- لیست پارسرهای موردنیاز
			local ensure_installed = {
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
			}

			-- فقط پارسرهایی که هنوز نصب نیستند را نصب کن
			local already = require("nvim-treesitter.config").get_installed()
			local to_install = vim.iter(ensure_installed)
				:filter(function(p)
					return not vim.tbl_contains(already, p)
				end)
				:totable()
			if #to_install > 0 then
				require("nvim-treesitter").install(to_install)
			end

			-- روشن کردن highlight و indent با FileType (API جدید)
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = true,
				},
			})
		end,
	},
}
