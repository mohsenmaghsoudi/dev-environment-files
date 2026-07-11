-- lua/mohsen/plugins/ai.lua
-- ══════════════════════════════════════════════════════════════
--  دستیارهای AI (CLI) داخل ترمینال شناور Neovim
--
--    • Claude Code  → <leader>ac   (با اشتراک Claude Pro)
--    • Codex CLI    → <leader>ax   (با اشتراک ChatGPT)
--    • autocomplete → Copilot (در فایل copilot.lua، دست‌نخورده)
--
--  هر کدام در یک پنجره‌ی شناور وسط صفحه باز می‌شوند، در ریشه‌ی
--  پروژه‌ی فعلی. ترمینال‌ها بین باز و بسته toggle می‌شوند و وضعیت
--  جلسه حفظ می‌شود (بستن پنجره session را نمی‌کشد).
--
--  این فایل از ترمینال داخلی خود Neovim استفاده می‌کند (بدون
--  پلاگین اضافه) تا سبک و پایدار بماند.
-- ══════════════════════════════════════════════════════════════

-- نگه‌داری وضعیت هر ترمینال AI (buffer و window)
local state = {
	claude = { buf = nil, win = nil },
	codex = { buf = nil, win = nil },
}

-- ساخت/نمایش پنجره‌ی شناور برای یک ابزار
local function toggle_ai(name, cmd)
	local s = state[name]

	-- اگر پنجره باز است → ببند (ولی buffer/process را نگه دار)
	if s.win and vim.api.nvim_win_is_valid(s.win) then
		vim.api.nvim_win_hide(s.win)
		s.win = nil
		return
	end

	-- ابعاد پنجره‌ی شناور (۸۵٪ صفحه)
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.85)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " " .. name:upper() .. " ",
		title_pos = "center",
	}

	-- اگر buffer از قبل هست (ترمینال زنده) → فقط دوباره نمایش بده
	if s.buf and vim.api.nvim_buf_is_valid(s.buf) then
		s.win = vim.api.nvim_open_win(s.buf, true, win_opts)
		vim.cmd("startinsert")
		return
	end

	-- buffer جدید + اجرای CLI
	s.buf = vim.api.nvim_create_buf(false, true)
	s.win = vim.api.nvim_open_win(s.buf, true, win_opts)
	vim.fn.jobstart(cmd, {
		term = true,
		cwd = vim.fn.getcwd(),
		on_exit = function()
			-- وقتی CLI بسته شد، buffer را پاک کن تا دفعه‌ی بعد تازه باز شود
			if s.buf and vim.api.nvim_buf_is_valid(s.buf) then
				pcall(vim.api.nvim_buf_delete, s.buf, { force = true })
			end
			s.buf, s.win = nil, nil
		end,
	})
	vim.cmd("startinsert")
end

-- keymaps
vim.keymap.set("n", "<leader>ac", function()
	toggle_ai("claude", "claude")
end, { desc = "AI: Claude Code (toggle)" })
vim.keymap.set("n", "<leader>ax", function()
	toggle_ai("codex", "codex")
end, { desc = "AI: Codex (toggle)" })

-- داخل ترمینال شناور: <Esc> دو بار → مخفی کردن پنجره (نه کشتن session)
-- (یک <Esc> برای خود CLI آزاد می‌ماند)
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(ev)
		local bufname = vim.api.nvim_buf_get_name(ev.buf)
		if bufname:match("claude") or bufname:match("codex") then
			vim.keymap.set("t", "<Esc><Esc>", function()
				local win = vim.api.nvim_get_current_win()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_hide(win)
				end
			end, { buffer = ev.buf, desc = "Hide AI terminal" })
		end
	end,
})

-- این فایل پلاگینی برنمی‌گرداند (فقط keymap تعریف می‌کند)
return {}
