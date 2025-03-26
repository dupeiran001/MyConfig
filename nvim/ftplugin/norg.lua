vim.keymap.set("n", "<cr>", "<Plug>(neorg.esupports.hop.hop-link)", { desc = "[neorg] Jump to Link", buffer = true })
vim.keymap.set(
	"n",
	"<,",
	"<Plug>(neorg.promo.demote)",
	{ desc = "[neorg] Demote Object (Non-Recursively)", buffer = true }
)
vim.keymap.set(
	"n",
	"<<",
	"<Plug>(neorg.promo.demote.nested)",
	{ desc = "[neorg] Demote Object (Recursively)", buffer = true }
)
vim.keymap.set(
	"n",
	">.",
	"<Plug>(neorg.promo.promote)",
	{ desc = "[neorg] Promote Object (Non-Recursively)", buffer = true }
)
vim.keymap.set(
	"n",
	">>",
	"<Plug>(neorg.promo.promote.nested)",
	{ desc = "[neorg] Promote Object (Recursively)", buffer = true }
)

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.norg",
	callback = function()
		if vim.g.disable_autoformat then
			return
		end

		-- Save the current cursor position
		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		-- Format the entire file
		vim.cmd("normal! gg=G")
		-- Restore the cursor position
		vim.api.nvim_win_set_cursor(0, cursor_pos)
	end,
})
