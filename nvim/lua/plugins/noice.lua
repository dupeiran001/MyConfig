return {
	"folke/noice.nvim",
	cond = function()
		return vim.g.started_by_firenvim == nil or vim.g.started_by_firevim == false
	end,
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	keys = {
		{ "<leader>n", "<cmd>Noice<cr>", desc = "Noice" },
	},
	opts = {
		presets = {
			bottom_search = true,
			command_palette = true,
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true },
			},
		},
		views = {
			cmdline_popup = {
				border = {
					style = "none",
					padding = { 1, 2 },
				},
				filter_options = {},
				win_options = {
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				},
			},
		},
		lsp = {
			signature = {
				auto_open = { enabled = false },
			},
		},
	},
}
