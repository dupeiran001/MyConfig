local M = {}

local wezterm = require("wezterm")

-- wezTerm has a nerd font fallback, so use a non-patched version here.
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
  M.font = wezterm.font_with_fallback({
    { family = "FiraCode Nerd Font", weight = "Regular" },
    -- Here we explicitly ask for the 'Regular' weight.
    -- You can change 'Regular' to 'Light' or another weight
    -- you found with the fc-list command.
    { family = "Fira Code",    weight = "Regular" },
    { family = "CaskaydiaCove NF", weight = "Regular" },
    { family = "Cascadia Code",    weight = "Regular" },
    "Symbols Nerd Font",

    -- The rest of the fallbacks can remain simple strings
    "Cascadia Code",
    "FiraCode Nerd Font",
    "Noto Color Emoji",
    "KanjiStrokeOrders"
  })
  M.font_size = 12
  M.bold_brightens_ansi_colors = true
  M.freetype_load_target = "Normal"
  M.line_height = 1.1
  M.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
  M.underline_position = -7
  --M.dpi = 164 --NOTE: buggy on wayland
elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
  M.font = wezterm.font("Cascadia Code")
  M.font_size = 10.5
  M.bold_brightens_ansi_colors = true
  M.freetype_load_target = "Light"
  M.line_height = 1.1
  M.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
  M.underline_position = -7
else
  M.font = wezterm.font("Cascadia Code")
  M.font_size = 13.5
  M.bold_brightens_ansi_colors = true
  M.freetype_load_target = "Light"
  M.line_height = 1.05
  M.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
  M.underline_position = -7
end

M.enable_kitty_graphics = true

return M