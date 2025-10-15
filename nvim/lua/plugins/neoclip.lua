return {
	"AckslD/nvim-neoclip.lua",
	dependencies = {
		{ "kkharji/sqlite.lua", module = "sqlite" },
		-- you'll need at least one of these
		-- {'nvim-telescope/telescope.nvim'},
		-- {'ibhagwan/fzf-lua'},
	},
	config = function()
		require("neoclip").setup({
			history = 1000,
			length_limit = 1048576,
			continuous_sync = true,
			enable_persistent_history = false,
		})
	end,
}
