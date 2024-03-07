return {
  "nvim-lualine/lualine.nvim",

  opts = function()
    -- bubble theme
    return {
      options = {
        component_separators = '|',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = '' }, right_padding = 2 } },
        lualine_c = {
          {
            "filetype",
            icon_only = true,
            separator = { left = "" },
            padding = { left = 1, right = 0 },
          },
          {
            'filename',
          },

          {
            "%{%v:lua.require'nvim-navic'.get_location()%}",
            separator = { left = "" }
          },
        },
        lualine_z = { {
          function()
            return " " .. os.date("%R")
          end,
          separator = { right = '' },
          left_padding = 2
        } }
      },
    }
  end
}
