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

local background = "#2D3250"

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background_shape = "#7077A1"
	local foreground = "#EEF5FF"

	if hover then
		background_shape = "#8D9EFF"
		foreground = "#FFFFFF"
	elseif tab.is_active then
		background_shape = "#F6B17A"
		foreground = "#FFFFDD"
	end

	local title = tab_title(tab)

	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = background_shape } },
		{ Background = { Color = background } },
		{ Text = " " },
		{ Foreground = { Color = foreground } },
		{ Background = { Color = background_shape } },
		{ Text = title },
		{ Foreground = { Color = background_shape } },
		{ Background = { Color = background } },
		{ Text = " " },
	}
end)

local M = {}

M.use_fancy_tab_bar = false
M.hide_tab_bar_if_only_one_tab = true

M.colors = {
	tab_bar = {
		-- The color of the strip that goes along the top of the window
		-- (does not apply when fancy tab bar is in use)
		background = background,

		-- The new tab button that let you create new tabs
		new_tab = {
			bg_color = background,
			fg_color = "#DCF2F1",
		},

		-- You can configure some alternate styling when the mouse pointer
		-- moves over the new tab button
		new_tab_hover = {
			bg_color = "#8D9EFF",
			fg_color = "#FFFFFF",

			italic = false,

			-- The same options that were listed under the `active_tab` section above
			-- can also be used for `new_tab_hover`.
		},
	},
}

return M
