return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	branch = "main",
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	opts = {
		ensure_installed = {
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
		},
		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = false,
				node_decremental = "<bs>",
			},
		},
	},
	config = function(_, opts)
		require("nvim-treesitter").setup(opts)
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		})
	end,
}
