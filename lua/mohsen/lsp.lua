local keymap = vim.keymap -- for conciseness
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf, silent = true }

		-- set keybinds
		opts.desc = "Show LSP references"
		keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

		opts.desc = "Show LSP definition"
		keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definition

		opts.desc = "Show LSP implementations"
		keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

		opts.desc = "Show LSP type definitions"
		keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

		opts.desc = "Show line diagnostics"
		keymap.set("n", "gl", vim.diagnostic.open_float, opts) -- show diagnostics for line (gl چون <leader>d با کلیدهای DAP تداخل داشت)

		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, opts) -- jump to previous diagnostic in buffer
		--
		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, opts) -- jump to next diagnostic in buffer

		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
	end,
})

-- vim.lsp.inlay_hint.enable(true)

local severity = vim.diagnostic.severity

vim.diagnostic.config({
	signs = {
		text = {
			[severity.ERROR] = " ",
			[severity.WARN] = " ",
			[severity.HINT] = "󰠠 ",
			[severity.INFO] = " ",
		},
	},
})

-- ══════════════════════════════════════════════════════════════
-- Roslyn (C#) — keymaps و features
-- چون نسخه جدید roslyn.nvim دیگر on_attach نمی‌پذیرد، اینجا با یک
-- autocmd مستقل LspAttach که فقط روی client روسلین فعال می‌شود،
-- کلیدها را ست می‌کنیم. اینطوری مطمئناً اجرا می‌شوند.
-- ══════════════════════════════════════════════════════════════
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("RoslynKeymaps", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or client.name ~= "roslyn" then
			return
		end

		local bufnr = ev.buf

		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "C#: " .. desc })
		end

		-- ────────────────────────────────────────────────
		-- اول keymap ها را می‌سازیم تا اگر بخش‌های بعدی (code lens / inlay)
		-- به هر دلیلی ارور دادند، کلیدها همچنان ساخته شده باشند.
		-- ────────────────────────────────────────────────

		-- Toggle inlay hints
		map("<leader>Ch", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle Inlay Hints")

		-- اجرای code lens — اگر به command مخصوص VS Code خورد (مثل
		-- peekReferences) به‌جای ارور قرمز، references را با Telescope باز کن
		map("<leader>CL", function()
			local ok, err = pcall(vim.lsp.codelens.run)
			if not ok and tostring(err):match("peekReferences") then
				vim.cmd("Telescope lsp_references")
			end
		end, "Run Code Lens")

		-- Fix All
		map("<leader>Cf", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.fixAll" } },
				apply = true,
			})
		end, "Fix All")

		-- Organize imports — اکشن «remove unnecessary usings» را خودکار اعمال
		-- می‌کند. عمداً «Fix All» را رد می‌کنیم تا فقط همین فایل تمیز شود و
		-- یک اکشن منحصر بماند (وگرنه منوی انتخاب باز می‌شود).
		map("<leader>Ci", function()
			vim.lsp.buf.code_action({
				apply = true,
				filter = function(a)
					local t = (a.title or ""):lower()
					if t:find("fix all") then
						return false
					end
					return t:find("unnecessary") ~= nil
						or t:find("using") ~= nil
						or t:find("import") ~= nil
						or t:find("organize") ~= nil
				end,
			})
		end, "Organize Imports")

		-- Restart Roslyn (دستور جدید؛ :Roslyn restart منسوخ شده)
		map("<leader>Cs", "<cmd>lsp restart roslyn<cr>", "Restart Roslyn")

		-- ────────────────────────────────────────────────
		-- features: inlay hints و code lens
		-- همه داخل pcall تا هیچ ارور/deprecation کل callback را نشکند.
		-- codelens.refresh بدون آرگومان صدا زده می‌شود (فرم {bufnr} منسوخ شده).
		-- ────────────────────────────────────────────────

		-- Inlay hints به‌صورت پیش‌فرض خاموش است.
		-- علت: باگ runtime نسخه 0.12.x که هنگام نمایش hint خطای
		-- «Invalid 'col': out of range» می‌دهد. با <leader>Ch دستی روشن کن.
		-- pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })

		-- Code lens: refresh خودکار
		if client:supports_method("textDocument/codeLens") then
			pcall(vim.lsp.codelens.refresh)
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold" }, {
				buffer = bufnr,
				callback = function()
					pcall(vim.lsp.codelens.refresh)
				end,
			})
		end
	end,
})

-- ══════════════════════════════════════════════════════════════
-- محافظ inlay hints برای Neovim 0.12.x
-- در نسخه‌های dev نسخه‌ی 0.12، یک باگ در runtime باعث می‌شود موقع
-- تایپ (وقتی خط ناقص است یا کد خطا دارد) hint با col خارج از محدوده
-- گذاشته شود و خطای «Invalid 'col': out of range» بدهد.
-- راه‌حل: inlay hints را هنگام ورود به insert mode خاموش و هنگام خروج
-- دوباره روشن می‌کنیم. این دقیقاً همان نقطه‌ی کرش را می‌پوشاند.
-- ══════════════════════════════════════════════════════════════
local ih_grp = vim.api.nvim_create_augroup("InlayHintInsertGuard", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
	group = ih_grp,
	callback = function(ev)
		if vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }) then
			vim.b[ev.buf]._ih_was_on = true
			pcall(vim.lsp.inlay_hint.enable, false, { bufnr = ev.buf })
		end
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	group = ih_grp,
	callback = function(ev)
		if vim.b[ev.buf]._ih_was_on then
			vim.b[ev.buf]._ih_was_on = nil
			pcall(vim.lsp.inlay_hint.enable, true, { bufnr = ev.buf })
		end
	end,
})
