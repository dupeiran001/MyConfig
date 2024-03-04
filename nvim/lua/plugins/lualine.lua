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
        lualine_a = {{ "mode", separator = { left = '' }, right_padding = 2 }},
        lualine_z = {{
          function()
            return " " .. os.date("%R")
          end,
          separator = { right = '' }, left_padding = 2
        }}
      },
  }
end}
