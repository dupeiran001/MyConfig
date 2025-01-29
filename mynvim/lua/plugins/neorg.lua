return {
	"nvim-neorg/neorg",
	dependencies = {
		"benlubas/neorg-interim-ls",
		"saghen/blink.cmp",
	},
	lazy = true, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	ft = "norg",
	cmd = "Neorg",
	version = "*", -- Pin Neorg to the latest stable release
	opts = {
		load = {
			["core.defaults"] = {},
			["core.concealer"] = {
				config = {
					icon_preset = "diamond",
					icons = {
						heading = {
							highlights = {
								"@neorg.headings.n.1.prefix",
								"@neorg.headings.n.2.prefix",
								"@neorg.headings.n.3.prefix",
								"@neorg.headings.n.4.prefix",
								"@neorg.headings.n.5.prefix",
								"@neorg.headings.n.6.prefix",
							},
						},
					},
					init_open_folds = "never",
				},
			},
			["core.esupports.metagen"] = {
				config = {
					author = "Peiran Du",
					type = "auto",
				},
			},
			["core.export"] = {},
			["core.latex.renderer"] = {
				config = {
					conceal = false,
					render_on_enter = true,
					debounce_ms = 100, -- default 200
					dpi = 150, -- default 350
				},
			},
			["core.highlights"] = {
				config = {
					highlights = {
						headings = {
							["1"] = {
								title = "+@neorg.headings.n.1.title",
								prefix = "+@neorg.headings.n.1.prefix",
							},

							["2"] = {
								title = "+@neorg.headings.n.2.title",
								prefix = "+@neorg.headings.n.2.prefix",
							},

							["3"] = {
								title = "+@neorg.headings.n.3.title",
								prefix = "+@neorg.headings.n.3.prefix",
							},

							["4"] = {
								title = "+@neorg.headings.n.4.title",
								prefix = "+@neorg.headings.n.4.prefix",
							},

							["5"] = {
								title = "+@neorg.headings.n.5.title",
								prefix = "+@neorg.headings.n.5.prefix",
							},

							["6"] = {
								title = "+@neorg.headings.n.6.title",
								prefix = "+@neorg.headings.n.6.prefix",
							},
						},
					},
				},
			},
			["core.dirman"] = {
				config = {
					workspaces = {
						document = "~/Documents/document/",
					},
					default_workspace = "document",
				},
			},
			["core.keybinds"] = {
				config = {
					default_keybinds = true,
				},
			},
			["core.completion"] = {
				config = { engine = { module_name = "external.lsp-completion" } },
			},
			["external.interim-ls"] = {
				config = {
					-- default config shown
					completion_provider = {
						-- Enable or disable the completion provider
						enable = true,

						-- Show file contents as documentation when you complete a file name
						documentation = true,

						-- Try to complete categories provided by Neorg Query. Requires `benlubas/neorg-query`
						categories = false,

						-- suggest heading completions from the given file for `{@x|}` where `|` is your cursor
						-- and `x` is an alphanumeric character. `{@name}` expands to `[name]{:$/people:# name}`
						people = {
							enable = false,

							-- path to the file you're like to use with the `{@x` syntax, relative to the
							-- workspace root, without the `.norg` at the end.
							-- ie. `folder/people` results in searching `$/folder/people.norg` for headings.
							-- Note that this will change with your workspace, so it fails silently if the file
							-- doesn't exist
							path = "people",
						},
					},
				},
			},
		},
	},
}
