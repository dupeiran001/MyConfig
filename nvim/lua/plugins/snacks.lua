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
		indent = {
			priority = 1,
			enabled = true, -- enable indent guides
			char = "│",
			only_scope = false, -- only show indent guides of the scope
			only_current = false, -- only show indent guides in the current window
			hl = "SnacksIndent", ---@type string|string[] hl groups for indent guides
		},
	},
}
