return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		open_mapping = [[<c-\>]],
		direction = "float",
		close_on_exit = true,
	},
	init = function()
		-- solve exit error when toggleterm runs on backend
		vim.api.nvim_create_autocmd({ "TermEnter" }, {
			callback = function()
				for _, buffers in ipairs(vim.fn.getbufinfo()) do
					local filetype = vim.bo.filetype
					if filetype == "toggleterm" then
						vim.api.nvim_create_autocmd({ "BufWriteCmd", "FileWriteCmd", "FileAppendCmd" }, {
							buffer = buffers.bufnr,
							command = "q!",
						})
					end
				end
			end,
		})
	end,
}
