-- lua/mohsen/dap_util.lua
-- ══════════════════════════════════════════════════════════════
--  Helpers shared by dap.lua and neotest.lua
--
--  Why a separate module?  neotest-golang calls dap-go's setup() again
--  every time a test is debugged. If the dap-go options only lived in
--  dap.lua, the delve path and other settings would silently reset to
--  defaults after the first "Debug Nearest". With this module both files
--  use exactly the same options.
-- ══════════════════════════════════════════════════════════════
local M = {}

local data = vim.fn.stdpath("data")
M.mason_bin = data .. "/mason/bin/"

local function is_exe(path)
  return path ~= nil and path ~= "" and vim.fn.executable(path) == 1
end

-- ────────────────────────────────────────────────────────────
-- Go / delve
-- ────────────────────────────────────────────────────────────
function M.go_opts()
  local dlv = M.mason_bin .. "dlv"
  return {
    delve = {
      path = is_exe(dlv) and dlv or "dlv", -- Mason first, then PATH
      initialize_timeout_sec = 20,
      port = "${port}",
      args = {},
      build_flags = "",
      detached = false, -- works on WSL/Mac
    },
    -- dap-go already ships Debug / Debug (Arguments) / Debug Package /
    -- Attach / Debug test. Only add what it does not have.
    dap_configurations = {
      { type = "go", name = "Attach Remote", mode = "remote", request = "attach" },
    },
  }
end

-- ────────────────────────────────────────────────────────────
-- Python interpreter for neotest-python
-- Priority: venv chosen with venv-selector > neotest-python's own logic
-- (VIRTUAL_ENV, .venv, venv, pipenv, poetry)
-- ────────────────────────────────────────────────────────────
function M.python_for_tests(root)
  local ok, vs = pcall(require, "venv-selector")
  if ok then
    local p = vs.python()
    if p and p ~= "" then
      return { p }
    end
  end
  return require("neotest-python.base").get_python_command(root)
end

-- ────────────────────────────────────────────────────────────
-- netcoredbg
-- Mason requests the old asset (osx-amd64.tar.gz), which no longer exists
-- on GitHub, so we install it ourselves with :NetcoredbgInstall
-- ────────────────────────────────────────────────────────────
M.netcoredbg_version = "3.2.0-1092"
M.netcoredbg_dir = data .. "/netcoredbg"

function M.find_netcoredbg()
  local candidates = {
    M.netcoredbg_dir .. "/netcoredbg/netcoredbg", -- installed by :NetcoredbgInstall
    M.mason_bin .. "netcoredbg",
    data .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg",
    vim.fn.exepath("netcoredbg"), -- brew etc.
  }
  for _, c in ipairs(candidates) do
    if is_exe(c) then
      return c
    end
  end
end

function M.install_netcoredbg()
  local notify = function(msg, lvl)
    vim.notify(msg, lvl or vim.log.levels.INFO, { title = "netcoredbg" })
  end

  if vim.uv.os_uname().sysname ~= "Darwin" then
    return notify("This command is for macOS only. On Linux use :MasonInstall netcoredbg", vim.log.levels.WARN)
  end

  -- sysctl reports the real hardware even when nvim runs under Rosetta
  local is_arm = vim.trim(vim.fn.system("sysctl -n hw.optional.arm64 2>/dev/null")) == "1"
  if not is_arm then
    return notify(
      "This release only has an arm64 macOS build. On Intel use: brew install netcoredbg",
      vim.log.levels.WARN
    )
  end

  local url = ("https://github.com/Samsung/netcoredbg/releases/download/%s/netcoredbg-osx-arm64.zip"):format(
    M.netcoredbg_version
  )
  local dest = M.netcoredbg_dir
  local zip = dest .. ".zip"
  local q = vim.fn.shellescape

  local script = table.concat({
    "set -e",
    ("rm -rf %s %s"):format(q(dest), q(zip)),
    ("mkdir -p %s"):format(q(dest)),
    ("curl -fL --retry 3 -o %s %s"):format(q(zip), q(url)),
    ("unzip -q -o %s -d %s -x '__MACOSX/*'"):format(q(zip), q(dest)),
    ("rm -f %s"):format(q(zip)),
    ("chmod +x %s"):format(q(dest .. "/netcoredbg/netcoredbg")),
    ("xattr -dr com.apple.quarantine %s 2>/dev/null || true"):format(q(dest)),
  }, "\n")

  notify("Downloading netcoredbg " .. M.netcoredbg_version .. " ...")
  vim.system({ "sh", "-c", script }, { text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 and M.find_netcoredbg() then
        notify("Installed: " .. M.find_netcoredbg())
      else
        notify("Install failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end

return M
