return {
  -- use nord theme
  {
    "shaunsingh/nord.nvim",
    config = function()
      vim.g.nord_contrast = true                  -- Make sidebars and popup menus like nvim-tree and telescope have a different background
      vim.g.nord_borders = true                   -- Enable the border between verticaly split windows visable
      vim.g.nord_disable_background = false       --	Disable the setting of background color so that NeoVim can use your terminal background
      vim.g.nord_cursorline_transparent = false   --	Set the cursorline transparent/visible
      vim.g.nord_enable_sidebar_background = true --	Re-enables the background of the sidebar if you disabled the background of everything
      vim.g.nord_italic = true                    --	enables/disables italics
      vim.g.nord_uniform_diff_background = true   --	enables/disables colorful backgrounds when used in diff mode
      vim.g.nord_bold = true                      --enables/disables bold

      -- Load the colorscheme
      require('nord').set()
    end,
  },
  --
  --	-- configure lazy to use nord theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
    config = function()
      -- change colorscheme
      vim.cmd [[colorscheme nord]]

      -- and `#ffffff` to the color you want
      -- see `:h nvim_set_hl` for more options
      -- Tabnine Cmp Icom color
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindTabnine",
        { link = "CmpItemKindCopilot", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#8fbcbb", underline = false, bold = false })

      -- Cmp Item Menu -> signiture
      vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#6DA4AA" })
      -- Value
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindVariable",
        { link = "CmpItemKindValue", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindConstant",
        { link = "CmpItemKindValue", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindProperty",
        { link = "CmpItemKindValue", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(0, "CmpItemKindField", { link = "CmpItemKindValue", underline = false, bold = false })
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindEnumMember",
        { link = "CmpItemKindValue", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindReference",
        { link = "CmpItemKindValue", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#86a7fc", underline = false, bold = false })

      -- Function
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindConstructor",
        { link = "CmpItemKindFunction", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindOperator",
        { link = "CmpItemKindFunction", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindEvent",
        { link = "CmpItemKindFunction", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindMethod",
        { link = "CmpItemKindFunction", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#f6b17a", underline = false, bold = false })

      vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#fde030", underline = false, bold = false })

      vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#ff90bc", underline = false, bold = false })

      vim.api.nvim_set_hl(0, "CmpItemKindEnum", { link = "CmpITemKindModule", underline = false, bold = false })
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindClass",
        { link = "CmpItemKindFunction", underline = false, bold = false }
      )
      vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindFunction", underline = false, bold = false })
      vim.api.nvim_set_hl(
        0,
        "CmpItemKindStruct",
        { link = "CmpItemKindFunction", underline = false, bold = false }
      )
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

      -- win bar background
      vim.api.nvim_set_hl(0, "WinBar", { link = "StatusLine" })
      vim.api.nvim_set_hl(0, "WinBarNC", { link = "StatusLineNC" })
      vim.api.nvim_set_hl(0, "NeoTreeTabInactive", { link = "BufferInactive" })
      vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", { link = "BufferInactive" })
      vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive", { link = "BufferActive" })
      vim.api.nvim_set_hl(0, "NeoTreeTabActive", { link = "BufferActive" })

      vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { link = "BufferLineTabSelected" })
      vim.api.nvim_set_hl(0, "BufferLineFill", { link = "BufferLineBackground" })
      vim.api.nvim_set_hl(0, "BufferLineSeparator", { link = "BufferLineBackground" })
    end,
  },
}
