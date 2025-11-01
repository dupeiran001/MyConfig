local M = {}

local wezterm = require("wezterm")

local function is_niri()
  return os.getenv('NIRI_SOCKET') ~= nil
end

if is_niri() then
  M.window_decorations = "RESIZE"
end

return M
