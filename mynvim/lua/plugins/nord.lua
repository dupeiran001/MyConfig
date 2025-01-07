return {
  "dupeiran001/nord.nvim",
  lazy = false,
  priority = 1000,
  init = function()
    -- vim.api.nvim_set_hl(0, "NormalFloat", {link = "Normal", force = true})
    -- vim.api.nvim_set_hl(0, "FloatBorder", {link = "Normal", force = true})
    -- vim.api.nvim_set_hl(0, "NeoTreeNormal", {link = "Normal", force = true})
    -- vim.api.nvim_set_hl(0, "NeoTreeNormalNC", {link = "Normal", force = true})
  end,
  config = function()
    require('onenord').setup({
      theme = nil,     -- "dark" or "light". Alternatively, remove the option and set vim.o.background instead
      borders = true,  -- Split window borders
      fade_nc = false, -- Fade non-current windows, making them more distinguishable
      -- Style that is applied to various groups: see `highlight-args` for options
      styles = {
        comments = "NONE",
        strings = "NONE",
        keywords = "NONE",
        functions = "italic",
        variables = "bold",
        diagnostics = "underline",
      },
      disable = {
        background = false,       -- Disable setting the background color
        float_background = false, -- Disable setting the background color for floating windows
        cursorline = false,       -- Disable the cursorline
        eob_lines = false,        -- Hide the end-of-buffer lines
      },
      -- Inverse highlight for different groups
      inverse = {
        match_paren = false,
      },
      custom_highlights = {
        -- ["NeoTreeNormal"] = { guibg = "NONE" }

        ["@neorg.headings.n.1.prefix"] = { fg = "#BF616A" },
        ["@neorg.headings.n.1.title"]  = { fg = "#BF616A" },
        ["@neorg.headings.n.2.prefix"] = { fg = "#D08770" },
        ["@neorg.headings.n.2.title"]  = { fg = "#D08770" },
        ["@neorg.headings.n.3.prefix"] = { fg = "#EBCB8B" },
        ["@neorg.headings.n.3.title"]  = { fg = "#EBCB8B" },
        ["@neorg.headings.n.4.prefix"] = { fg = "#A3BE8C" },
        ["@neorg.headings.n.4.title"]  = { fg = "#A3BE8C" },
        ["@neorg.headings.n.5.prefix"] = { fg = "#B48EAD" },
        ["@neorg.headings.n.5.title"]  = { fg = "#B48EAD" },
        ["@neorg.headings.n.6.prefix"] = { fg = "#81A1C1" },
        ["@neorg.headings.n.6.title"]  = { fg = "#81A1C1" }

      },                  -- Overwrite default highlight groups
      custom_colors = {}, -- Overwrite default colors
    })
  end,
}
