return {
	"dupeiran001/bufferline.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"famiu/bufdelete.nvim",
		-- "dupeiran001/nord.nvim",
	},
	preority = 500,
	lazy = false,
	keys = {
		{ "<leader>b<S-l>", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all left buffers" },
		{ "<leader>b<S-r>", "<cmd>BufferLineCloseRight<cr>", desc = "Close all right buffers" },
		{ "<leader>bl", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer to left" },
		{ "<leader>br", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer to right" },
		{ "<leader>bd", "<cmd>Bdelete<cr>", desc = "Delete current buffer" },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Bufferline cycle prev" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Bufferline cycle next" },
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Buffer pinning" },
		{
			"<leader>1",
			function()
				require("bufferline").go_to(1, true)
			end,
			desc = "goto Buffer 1",
		},
		{
			"<leader>2",
			function()
				require("bufferline").go_to(2, true)
			end,
			desc = "goto Buffer 2",
		},
		{
			"<leader>3",
			function()
				require("bufferline").go_to(3, true)
			end,
			desc = "goto Buffer 3",
		},
		{
			"<leader>4",
			function()
				require("bufferline").go_to(4, true)
			end,
			desc = "goto Buffer 4",
		},
		{
			"<leader>5",
			function()
				require("bufferline").go_to(5, true)
			end,
			desc = "goto Buffer 5",
		},
		{
			"<leader>6",
			function()
				require("bufferline").go_to(6, true)
			end,
			desc = "goto Buffer 6",
		},
		{
			"<leader>7",
			function()
				require("bufferline").go_to(7, true)
			end,
			desc = "goto Buffer 7",
		},
		{
			"<leader>8",
			function()
				require("bufferline").go_to(8, true)
			end,
			desc = "goto Buffer 8",
		},
		{
			"<leader>9",
			function()
				require("bufferline").go_to(9, true)
			end,
			desc = "goto Buffer 9",
		},
	},
	opts = function()
		-- local bufferline_hl = require("nord").bufferline
		return {
			options = {
				close_command = "Bdelete! %d",
				themable = true,
				indicator = {
					icon = "▎",
					style = "icon",
				},
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				show_buffer_close_icons = false,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-Tree",
						text_align = "left",
						separator = false,
					},
				},
				numbers = "visible", --function(opts)
				--   local state = require("bufferline.state")
				--   local list = state.visible_components
				--   for buf in list do
				--     if buf.name == opts.name then
				--       return string.format('%s', buf.id)
				--     end
				--   end
				--   return opts
				--   -- return string.format('%s', opts.ordinal)
				--   -- return string.format('%s', state.current_element_index)
				-- end,
				show_tab_indicator = true,
				show_duplicate_prefix = true,
				separator_style = "none",
				always_show_bufferline = true,
				auto_toggle_bufferline = true,
				sort_by = "insert_after_current",
			},

			-- highlights = {
			--   background = { bg = color.bg },
			--   buffer_selected = { bg = color.bg_dark1 },
			--   buffer_visible = { bg = color.bg },
			-- }
			-- highlights = bufferline_hl,
		}
	end,
}
