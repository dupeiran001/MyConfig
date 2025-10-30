require("helpers")

local wezterm = require("wezterm")

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

local background = "#2E3440"

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background_shape = "#4C566A"
	local foreground = "#D8DEE9"
	local highlight = "#B48EAD"

	if hover then
		background_shape = "#5E81AC"
		foreground = "#D8DEE9"
	elseif tab.is_active then
		background_shape = "#81A1C1"
		foreground = "#D8DEE9"
	end

	local idx = ""
	if tab.is_active then
	elseif tab.tab_index <= 7 then
		idx = tostring(tab.tab_index + 1) .. " "
	elseif tab.tab_index == #tabs - 1 then
		idx = tostring(9) .. " "
	end

	local title, icon_color, icon = AppendIcon(tab)
	title = wezterm.truncate_right(title, max_width - 5 - #idx)

	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Attribute = { Italic = false } },
		{ Foreground = { Color = background_shape } },		{ Background = { Color = background } },
		{ Text = " " },
		{ Foreground = { Color = highlight } },
		{ Background = { Color = background_shape } },
		{ Text = idx },
		{ Foreground = { Color = icon_color } },
		{ Text = icon },
		{ Foreground = { Color = foreground } },		{ Background = { Color = background_shape } },
		{ Text = " " },
		{ Text = title },
		{ Foreground = { Color = background_shape } },		{ Background = { Color = background } },
		{ Text = "" },
	}
end)

wezterm.on("update-right-status", function(window, _pane)
	local bat = ""
	for _, b in ipairs(wezterm.battery_info()) do
		bat = string.format("%.0f%% ", b.state_of_charge * 100)
	end

	local cell = {
		{ Foreground = { Color = "#D8DEE9" } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = wezterm.strftime("%a %H:%M") },
		{ Foreground = { Color = "#88C0D0" } },
		{ Text = " | " },
		{ Foreground = { Color = "#D8DEE9" } },
		{ Text = bat },
	}

	window:set_right_status(wezterm.format(cell))
end)

local M = {}

M.use_fancy_tab_bar = false
M.hide_tab_bar_if_only_one_tab = false

M.native_macos_fullscreen_mode = true
M.tab_max_width = 22

M.colors = {
	tab_bar = {
		-- The color of the strip that goes along the top of the window
		-- (does not apply when fancy tab bar is in use)
		background = background,

		-- The new tab button that let you create new tabs
		new_tab = {
			bg_color = background,
			fg_color = "#D8DEE9",
		},

		-- You can configure some alternate styling when the mouse pointer
		-- moves over the new tab button
		new_tab_hover = {
			bg_color = "#5E81AC",
			fg_color = "#D8DEE9",

			italic = false,
		},
	},
}

return M
