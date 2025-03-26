return {
	"kawre/leetcode.nvim",
	build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
	lazy = true,
	cmd = "Leet",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		-- "ibhagwan/fzf-lua",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	opts = {
		-- configuration goes here
		lang = "rust",
		image_support = false,
		storage = {
			home = vim.fn.stdpath("data") .. "/leetcode",
			cache = vim.fn.stdpath("cache") .. "/leetcode",
		},
		hooks = {
			---@type fun(question: lc.ui.Question)[]
			["question_enter"] = {
				function()
					-- os.execute "sleep 1"
					local file_extension = vim.fn.expand("%:e")
					if file_extension == "rs" then
						local bash_script = tostring(vim.fn.stdpath("data") .. "/leetcode/rust_init.sh")
						local success, error_message = os.execute(bash_script)
						if success then
							print("Successfully updated rust-project.json")
							vim.cmd("LspRestart rust_analyzer")
						else
							print("Failed update rust-project.json. Error: " .. error_message)
						end
					end
				end,
			},
		},
		console = {
			open_on_runcode = true, ---@type boolean

			dir = "row", ---@type lc.direction

			size = { ---@type lc.size
				width = "90%",
				height = "75%",
			},

			result = {
				size = "60%", ---@type lc.size
			},

			testcase = {
				virt_text = true, ---@type boolean

				size = "40%", ---@type lc.size
			},
		},
		theme = {
			["alt"] = {
				bg = "#2E3440",
			},
			["normal"] = {
				fg = "#D8DEE9",
			},
		},
	},
}
