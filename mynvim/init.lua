local function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "' .. directory .. '"')
  if pfile == nil then
    error("error config dir: dir not exist", 1)
  end
  for filename in pfile:lines() do
    if not (filename == "." or filename == "..") then
      i = i + 1
      t[i] = filename
    end
  end
  pfile:close()
  return t
end

local config_root = vim.fn.stdpath("config")
package.path = config_root .. "/?.lua;" .. package.path

-- load other configs
for _, i in pairs(scandir("$HOME/.config/mynvim/lua/config")) do
  local filename = string.gsub(i, ".lua", "")
  require("config." .. filename .. "")
end


-- startup with lazy.nvim
local bootstrap_status, _ = pcall(require, "bootstrap")
if not bootstrap_status then
  error("cannot found bootstrap.lua in root directory, exiting")
end
