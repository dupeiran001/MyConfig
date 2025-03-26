-- return {
--   "giuxtaposition/blink-cmp-copilot",
--   dependencies = "zbirenbaum/copilot.lua",
--   lazy = true,
--   event = "InsertEnter",
-- }

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	build = ":Copilot auth",
	event = "InsertEnter",
	opts = {
		suggestion = { enabled = true },
		panel = { enabled = true },
		filetypes = {
			markdown = true,
			help = true,
		},
	},
}
