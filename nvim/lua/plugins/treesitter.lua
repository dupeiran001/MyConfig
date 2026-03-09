return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	opts = {
		install_dir = vim.fn.stdpath("data") .. "/site",
	},
	config = function(_, opts)
		local ts = require("nvim-treesitter")
		local ensure_installed = {
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"markdown",
			"markdown_inline",
			"rust",
			"bash",
			"regex",
			"norg",
			"norg_meta",
		}

		local function register_neorg_parsers()
			local parser_configs = require("nvim-treesitter.parsers")
			parser_configs.norg = {
				install_info = {
					url = "https://github.com/nvim-neorg/tree-sitter-norg",
					files = { "src/parser.c", "src/scanner.cc" },
					revision = "6348056b999f06c2c7f43bb0a5aa7cfde5302712",
					use_makefile = true,
				},
			}
			parser_configs.norg_meta = {
				install_info = {
					url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
					files = { "src/parser.c" },
					revision = "a479d1ca05848d0b51dd25bc9f71a17e0108b240",
					use_makefile = true,
				},
			}
		end

		local group = vim.api.nvim_create_augroup("UserTreesitterConfig", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "TSUpdate",
			callback = register_neorg_parsers,
		})
		register_neorg_parsers()

		ts.setup(opts)

		if vim.fn.executable("tree-sitter") == 1 then
			local installed = ts.get_installed("parsers")
			local missing = {}
			for _, lang in ipairs(ensure_installed) do
				if not vim.tbl_contains(installed, lang) then
					table.insert(missing, lang)
				end
			end
			if #missing > 0 then
				ts.install(missing)
			end
		end

		local ft_group = vim.api.nvim_create_augroup("UserTreesitterFileType", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = ft_group,
			callback = function(args)
				local bufnr = args.buf
				if vim.bo[bufnr].buftype ~= "" then
					return
				end

				local ok = pcall(vim.treesitter.start, bufnr)
				if ok then
					vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
	init = function()
		vim.opt.smartindent = true -- make indenting smarter again
		vim.opt.autoindent = true -- make indenting smarter again
	end,
}
