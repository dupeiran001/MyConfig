local M = {}

local wezterm = require("wezterm")
local act = wezterm.action

local function is_wayland()
	return os.getenv("WAYLAND_DISPLAY") ~= nil
end

local copy_action
local paste_action

if is_wayland() then
	copy_action = wezterm.action_callback(function(window, pane)
		local sel = window:get_selection_text_for_pane(pane)
		if sel and sel ~= "" then
			local success, stdout, stderr = wezterm.run_child_process({ "wl-copy", sel })
		end
	end)
	paste_action = wezterm.action_callback(function(window, pane)
		local success, stdout, stderr = wezterm.run_child_process({ "wl-paste", "--no-newline" })
		if success and stdout and stdout ~= "" then
			pane:paste(stdout)
		end
	end)
else
	copy_action = act.CopyTo("Clipboard")
	paste_action = act.PasteFrom("Clipboard")
end

M.keys = {
	{
		key = "c",
		mods = "CTRL|SHIFT",
		action = copy_action,
	},
	{
		key = "v",
		mods = "CTRL|SHIFT",
		action = paste_action,
	},
	{
		key = "x",
		mods = "ALT",
		action = act.CloseCurrentTab({ confirm = false }),
	},
	{
		key = "=",
		mods = "ALT",
		action = act.SpawnTab("DefaultDomain"),
	},
	{
		key = "1",
		mods = "ALT",
		action = act.ActivateTab(0),
	},
	{
		key = "1",
		mods = "ALT",
		action = act.ActivateTab(0),
	},
	{
		key = "2",
		mods = "ALT",
		action = act.ActivateTab(1),
	},
	{
		key = "3",
		mods = "ALT",
		action = act.ActivateTab(2),
	},
	{
		key = "4",
		mods = "ALT",
		action = act.ActivateTab(3),
	},
	{
		key = "5",
		mods = "ALT",
		action = act.ActivateTab(4),
	},
	{
		key = "6",
		mods = "ALT",
		action = act.ActivateTab(5),
	},
	{
		key = "7",
		mods = "ALT",
		action = act.ActivateTab(6),
	},
	{
		key = "8",
		mods = "ALT",
		action = act.ActivateTab(7),
	},
	{
		key = "9",
		mods = "ALT",
		action = act.ActivateTab(8),
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
