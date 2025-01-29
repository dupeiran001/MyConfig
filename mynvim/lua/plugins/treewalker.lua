return {
	"aaronik/treewalker.nvim",
	lazy = true,
	keys = {
		{ "<C-h>", "<cmd>Treewalker Left<cr>", desc = "Treewalker left" },
		{ "<C-l>", "<cmd>Treewalker Right<cr>", desc = "Treewalker right" },
		{ "<C-j>", "<cmd>Treewalker Down<cr>", desc = "Treewalker down" },
		{ "<C-k>", "<cmd>Treewalker Up<cr>", desc = "Treewalker up" },
	},
	-- The following options are the defaults.
	-- Treewalker aims for sane defaults, so these are each individually optional,
	-- and setup() does not need to be called, so the whole opts block is optional as well.
	opts = {
		-- Whether to briefly highlight the node after jumping to it
		highlight = true,

		-- How long should above highlight last (in ms)
		highlight_duration = 250,

		-- The color of the above highlight. Must be a valid vim highlight group.
		-- (see :h highlight-group for options)
		highlight_group = "CursorLine",
	},
}
