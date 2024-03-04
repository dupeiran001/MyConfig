lvim.colorscheme = "nord"
vim.g.nord_italic = false
vim.g.nord_contrast = false
vim.g.nord_border = false
vim.g.nord_cursorline_transparent = false
vim.g.nord_enable_sidebar_background = true
vim.g.nord_uniform_diff_background = true

lvim.transparent_window = true

lvim.builtin.treesitter.rainbow.enable = true

-- StatusLineInactive

lvim.autocommands = {
  {
    { "ColorScheme" },
    {
      pattern = "*",
      callback = function()
        -- change `Normal` to the group you want to change
        -- and `#ffffff` to the color you want
        -- see `:h nvim_set_hl` for more options
        -- Tabnine Cmp Icom color
        vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { link = "CmpItemKindCopilot", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#8fbcbb", underline = false, bold = false })

        -- Value
        vim.api.nvim_set_hl(0, "CmpItemKindVariable",
          { link = "CmpItemKindValue", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindConstant", { link = "CmpItemKindValue", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindValue", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindField", { link = "CmpItemKindValue", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { link = "CmpItemKindValue", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindReference", { link = "CmpItemKindValue", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#86a7fc", underline = false, bold = false })

        -- Function
        vim.api.nvim_set_hl(0, "CmpItemKindConstructor",
          { link = "CmpItemKindFunction", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindOperator", { link = "CmpItemKindFunction", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindEvent", { link = "CmpItemKindFunction", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#f6b17a", underline = false, bold = false })

        vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#fde030", underline = false, bold = false })

        vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#ff90bc", underline = false, bold = false })

        vim.api.nvim_set_hl(0, "CmpItemKindEnum", { link = "CmpITemKindModule", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindClass", { link = "CmpItemKindFunction", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindFunction", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindStruct", { link = "CmpItemKindFunction", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#C499F3", underline = false, bold = false })

        vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#86a789", underline = false, bold = false })

        -- File highlight
        vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#c0c0c0", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#c0c0c0", underline = false, bold = false })
        ---- Snippet & buffer text highlight
        --vim.api.nvim_set_hl(0, "CmpItemKindSnippetDefault", { fg = "#a0a0a0", underline = false, bold = false })
        vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#a0a0a0", underline = false, bold = false })

        -- Cmp Icon Color Group
        vim.api.nvim_set_hl(0, "CmpItemKind", { fg = "#a0a0a0", underline = false, bold = false })
        -- Cmp Abbrr match Color
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#92C7CF", underline = false, bold = true })
        -- inlay hint color
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#67729D", underline = false, bold = false })
        -- seperator color
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#67729D", underline = false, bold = false })
      end,
    },
  },
}

-- set icons
lvim.icons.kind.Text = "󰉿"
lvim.icons.kind.Method = "󰆧"
lvim.icons.kind.Function = "󰊕"
lvim.icons.kind.Constructor = ""
lvim.icons.kind.Field = "󰜢"
lvim.icons.kind.Variable = "󰀫"
lvim.icons.kind.Class = "󰠱"
lvim.icons.kind.Interface = ""
lvim.icons.kind.Module = ""
lvim.icons.kind.Property = "󰜢"
lvim.icons.kind.Unit = "󰑭"
lvim.icons.kind.Value = "󰎠"
lvim.icons.kind.Enum = ""
lvim.icons.kind.Keyword = "󰌋"
lvim.icons.kind.Snippet = ""
lvim.icons.kind.Color = "󰏘"
lvim.icons.kind.File = "󰈙"
lvim.icons.kind.Reference = "󰈇"
lvim.icons.kind.Folder = "󰉋"
lvim.icons.kind.EnumMember = ""
lvim.icons.kind.Constant = "󰏿"
lvim.icons.kind.Struct = "󰙅"
lvim.icons.kind.Event = ""
lvim.icons.kind.Operator = "󰆕"
