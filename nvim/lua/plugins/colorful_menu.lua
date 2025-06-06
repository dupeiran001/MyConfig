return {
	"xzbdmw/colorful-menu.nvim",
	opts = {
		ls = {
			lua_ls = {
				-- Maybe you want to dim arguments a bit.
				arguments_hl = "@comment",
			},
			gopls = {
				-- When true, label for field and variable will format like "foo: Foo"
				-- instead of go's original syntax "foo Foo".
				add_colon_before_type = false,
			},
			["typescript-language-server"] = {
				extra_info_hl = "@comment",
			},
			["typescript-tools"] = {
				extra_info_hl = "@comment",
			},
			ts_ls = {
				extra_info_hl = "@comment",
			},
			tsserver = {
				extra_info_hl = "@comment",
			},
			vtsls = {
				extra_info_hl = "@comment",
			},
			["rust-analyzer"] = {
				-- Such as (as Iterator), (use std::io).
				extra_info_hl = "@comment",
			},
			clangd = {
				-- Such as "From <stdio.h>".
				extra_info_hl = "@comment",
			},
			roslyn = {
				extra_info_hl = "@comment",
			},

			-- If true, try to highlight "not supported" languages.
			fallback = true,
		},
		-- If the built-in logic fails to find a suitable highlight group,
		-- this highlight is applied to the label.
		fallback_highlight = "@variable",
		-- If provided, the plugin truncates the final displayed text to
		-- this width (measured in display cells). Any highlights that extend
		-- beyond the truncation point are ignored. Default 60.
		max_width = 60,
	},
	config = function(_, opts)
		require("colorful-menu").setup(opts)
	end,
}
