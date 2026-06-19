-- lua/mohsen/plugins/python.lua
-- ══════════════════════════════════════════════════════════════
--  Python IDE
--
--  تقسیم مسئولیت‌ها (مثل Go و C#):
--    • LSP / autocomplete / hover / type-check → pyright (after/lsp/pyright.lua)
--    • lint + format                           → ruff   (LSP + conform)
--    • تست                                     → neotest-python (neotest.lua, <leader>T…)
--    • دیباگ                                   → nvim-dap-python (dap.lua)
--    • venv selector + اجرا/REPL               → همین فایل (<leader>P…)
--
--  همه‌ی keymap های دستوری زیر پیشوند <leader>P هستند.
-- ══════════════════════════════════════════════════════════════
return {
	-- انتخاب‌گر محیط مجازی (venv) — مهم تا pyright/debugpy پکیج‌ها را پیدا کنند
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mfussenegger/nvim-dap-python",
		},
		ft = "python",
		opts = {
			dap_enabled = true, -- venv انتخاب‌شده به دیباگ هم وصل شود
		},
		keys = {
			{ "<leader>Pv", "<cmd>VenvSelect<cr>", desc = "Python: Select venv" },
		},
	},

	-- keymaps + features مخصوص فایل‌های پایتون
	{
		"neovim/nvim-lspconfig",
		ft = "python",
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function(ev)
					local bufnr = ev.buf
					local map = function(keys, cmd, desc)
						vim.keymap.set("n", keys, cmd, { desc = "Python: " .. desc, buffer = bufnr })
					end

					-- اجرا
					map("<leader>Pr", function()
						vim.cmd("write")
						vim.cmd("split | terminal python3 " .. vim.fn.shellescape(vim.fn.expand("%")))
						vim.cmd("startinsert")
					end, "Run File")

					-- REPL تعاملی
					map("<leader>Pi", function()
						vim.cmd("split | terminal python3")
						vim.cmd("startinsert")
					end, "Open REPL")

					-- مرتب‌سازی imports (ruff)
					map("<leader>Po", function()
						vim.lsp.buf.code_action({
							context = { only = { "source.organizeImports" } },
							apply = true,
						})
					end, "Organize Imports")

					-- رفع خودکار همه (ruff fix all)
					map("<leader>Pf", function()
						vim.lsp.buf.code_action({
							context = { only = { "source.fixAll" } },
							apply = true,
						})
					end, "Fix All (ruff)")
				end,
			})
		end,
	},
}
