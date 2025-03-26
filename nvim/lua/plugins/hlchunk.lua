return {
	"shellRaining/hlchunk.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		chunk = {
			enable = true,
			chars = {
				horizontal_line = "─",
				vertical_line = "│",
				left_top = "┌",
				left_bottom = "└",
				right_arrow = "─",
			},
			style = "#5E81AC",
			delay = 0,
			duration = 0,
		},
		indent = {
			enable = true,
			use_treesitter = true,
			delay = 0,
		},
		line_num = {
			enable = false,
		},
		blank = {
			enable = true,
		},
	},
}
