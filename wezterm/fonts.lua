local M = {}

local wezterm = require("wezterm")

-- wezTerm has a nerd font fallback, so use a non-patched version here.
M.font = wezterm.font("Cascadia Code")
M.font_size = 13.5
M.bold_brightens_ansi_colors = true
M.freetype_load_target = "Light"
M.line_height = 1.05
M.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

return M
