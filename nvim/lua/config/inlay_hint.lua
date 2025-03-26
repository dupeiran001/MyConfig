-- enable inaly hint by default
vim.lsp.inlay_hint.enable()

vim.api.nvim_create_user_command("ToggleInlayHints", function(_)
	local inlay_hint_enabled = vim.lsp.inlay_hint.is_enabled()
	vim.lsp.inlay_hint.enable(not inlay_hint_enabled)

	vim.notify("Inlay hints " .. (inlay_hint_enabled and "disabled" or "enabled"))
end, { desc = "Toggle Inlay Hint" })

vim.api.nvim_set_keymap(
	"n",
	"<Space>cI",
	"<cmd>ToggleInlayHints<CR>",
	{ noremap = true, silent = true, desc = "Toggle Inlay Hints" }
)
