return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	init = function()
		vim.g.snacks_animate = false
	end,
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		profiler = { enable = false },
		quickfile = { enable = true },
		scroll = { enable = true },
		---@class snacks.indent.Config
		---@field enabled? boolean
	},
}
