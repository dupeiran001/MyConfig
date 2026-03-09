return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = {
		select = {
			lookahead = true,
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
				["@function.outer"] = "V", -- linewise
				["@class.outer"] = "<c-v>", -- blockwise
			},
			include_surrounding_whitespace = true,
		},
	},
	config = function(_, opts)
		require("nvim-treesitter-textobjects").setup(opts)

		local select = require("nvim-treesitter-textobjects.select")
		local keymaps = {
			af = "@function.outer",
			["if"] = "@function.inner",
			ac = "@class.outer",
			ic = "@class.inner",
		}

		for lhs, query in pairs(keymaps) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(query, "textobjects")
			end, { desc = "Treesitter textobject" })
		end
	end,
}
