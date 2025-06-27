return {
	"sindrets/diffview.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	cmd = {
		"DiffviewClose",
		"DiffviewOpen",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewLog",
		"DiffviewRefresh",
		"DiffviewToggleFiles",
	},
	keys = {
		{
			"<leader>dd",
			function()
				local is_diff = function()
					local current_tab = vim.api.nvim_get_current_tabpage()
					local windows_in_tab = vim.api.nvim_tabpage_list_wins(current_tab)

					if #windows_in_tab == 0 then
						return false -- No windows in the tab
					end

					for _, win_id in ipairs(windows_in_tab) do
						if vim.wo[win_id].diff then
							--if not vim.api.nvim_win_get_option(win_id, "diff") then
							return true -- Found a window not in diff mode
						end
					end
					return false
				end

				if is_diff() then
					vim.cmd("DiffviewClose")
				else
					vim.cmd("DiffviewOpen")
				end
			end,
			desc = "Toggle Diffview",
		},
	},
	opts = {
		hooks = {
			diff_buf_read = function(bufnr)
				-- Change local options in diff buffers
				vim.opt_local.wrap = false
				vim.opt_local.list = false
				vim.opt_local.colorcolumn = { 80 }
			end,
			diff_buf_win_enter = function(bufnr, winid, ctx)
				-- Turn off cursor line for diffview windows because of bg conflict
				-- https://github.com/neovim/neovim/issues/9800
				vim.wo[winid].culopt = "number"
			end,
		},
	},
}
