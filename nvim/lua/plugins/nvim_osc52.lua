return {
	"ojroques/nvim-osc52",
	config = function()
		local function copy(lines, _)
			require("osc52").copy(table.concat(lines, "\n"))
		end

		local function paste()
			if vim.env.WAYLAND_DISPLAY then
				return { vim.fn.systemlist("wl-paste --no-newline 2>/dev/null"), "v" }
			elseif vim.env.DISPLAY then
				return { vim.fn.systemlist("xclip -selection clipboard -o 2>/dev/null"), "v" }
			end
			return { vim.fn.split(vim.fn.getreg("+"), "\n"), vim.fn.getregtype("+") }
		end

		vim.g.clipboard = {
			name = "osc52",
			copy = { ["+"] = copy, ["*"] = copy },
			paste = { ["+"] = paste, ["*"] = paste },
		}
	end,
}
