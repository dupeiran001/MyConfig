return {
	"dgox16/devicon-colorscheme.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function(_, _)
		local devicon_hl = require("nord").devicon_colorscheme
		require("devicon-colorscheme").setup({ colors = devicon_hl })
	end,
}
