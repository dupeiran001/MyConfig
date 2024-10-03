local M = {}

local wezterm = require("wezterm")
local act = wezterm.action

M.keys = {
	{
		key = "x",
		mods = "CMD",
		action = act.CloseCurrentTab({ confirm = false }),
	},
	{
		key = "+",
		mods = "CMD",
		action = act.SpawnTab("DefaultDomain"),
	},
}

M.key_tables = {

	search_mode = {
		{ key = "Enter", mods = "NONE", action = act.CopyMode("NextMatch") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "j", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "k", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{
			key = "PageUp",
			mods = "NONE",
			action = act.CopyMode("PriorMatchPage"),
		},
		{
			key = "PageDown",
			mods = "NONE",
			action = act.CopyMode("NextMatchPage"),
		},
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("NextMatchPage") },
	},
}

return M
