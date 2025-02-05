return {
	-- "dupeiran001/nord.nvim",
	dir = "~/Develop/nvim/nord.nvim/",
	lazy = false,
	priority = 1000,
	init = function()
		vim.cmd([[colorscheme nord]])
	end,
	opts = {
		style = "dark", -- The style can ether be 'light' or 'dark'
		transparent = false, -- Whether we should set the background color
		terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
		dim_inactive = false, -- Dims inactive windows
		lualine_bold = true, -- When `true`, section headers in the lualine theme will be bold

		light_brightness = 0.7, -- Adjusts the brightness of the colors of the **light** style. Number between 0 and 1, from dull to vibrant colors

		styles = {
			-- Style to be applied to different syntax groups
			-- Value is any valid attr-list value for `:help nvim_set_hl`
			comments = { italic = true },
			keywords = { italic = true },
			functions = {},
			variables = { italic = true },
			-- Background styles. Can be "dark", "transparent" or "normal"
			sidebars = "dark", -- style for sidebars, see below
			floats = "dark", -- style for floating windows
		},

		--- You can override specific highlights to use other groups or a hex color
		--- function will be called with a Highlights and ColorScheme table
		on_highlights = function(highlights, colors) end,

		--- You can override specific color groups to use other groups or a hex color
		--- function will be called with a ColorScheme table
		on_colors = function(colors) end,

		cache = false, -- When set to true, the theme will be cached for better performance

		---@type table<string, boolean|{enabled:boolean}>
		plugins = {
			all = false,
			-- uses your plugin manager to automatically enable needed plugins
			-- currently only lazy.nvim is supported
			auto = true,
			-- add any plugins here that you want to enable
			-- telescope = true,
		},
	},
}
