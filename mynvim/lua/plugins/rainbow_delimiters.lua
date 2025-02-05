return {
	"HiPhish/rainbow-delimiters.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = function()
		local rainbow_delimiters = require("rainbow-delimiters")
		return {
			strategy = {
				[""] = rainbow_delimiters.strategy["global"],
				vim = rainbow_delimiters.strategy["local"],
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
			},
			priority = {
				[""] = 110,
				lua = 210,
			},
			highlight = {
				"RainbowDelimiterNormal",
				"RainbowDelimiterOrange",
				"RainbowDelimiterYellow",
				"RainbowDelimiterGreen",
				"RainbowDelimiterCyan",
				"RainbowDelimiterBlue",
				"RainbowDelimiterViolet",
			},
		}
	end,
	config = function(_, opts)
		require("rainbow-delimiters.setup").setup(opts)
	end,
}
