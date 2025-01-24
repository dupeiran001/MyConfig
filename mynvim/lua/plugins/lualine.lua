return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nord.nvim",
    "nvim-tree/nvim-web-devicons",
    "folke/noice.nvim",
    --"SmiteshP/nvim-navic",
  },
  lazy = false,
  opts = function()
    local navic_location = function()
      local navic_stat, navic = pcall(require, "nvim-navic")
      if navic_stat then
        return navic.get_location()
      end
      return ""
    end

    local neorg_workspace = function()
      -- only enable when current filetype is norg
      if vim.bo.filetype == 'norg' then
        local dm = require('neorg').modules.get_module("core.dirman")
        local ws = dm.get_current_workspace()
        return "Neorg: " .. ws[1] .. " → " .. ws[2]
      end
      return ""
    end
    -- bubble theme
    return {
      options = {
        theme = "nord",
        component_separators = "|",
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = {

          { "mode", separator = { left = "" } },
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            right_padding = 2,
            left_padding = 2,
          },
        },
        lualine_b = {
          {
            "branch",
            disabled_filetypes = "norg"
          },
          {
            neorg_workspace
          }
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = " ",
            },
          },
          {
            "filetype",
            icon_only = true,
            separator = { right = "" },
            padding = { left = 1, right = 0 },
          },
          {
            "filename",
          },
          {
            -- "%{%v:lua.require'nvim-navic'.get_location()%}",
            navic_location,
            padding = { left = 1, right = 0 },
            separator = { left = "" },
          },
        },
        lualine_x = {
          -- stylua: ignore
          {
            function() return require("noice.api.status").command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            --color = LazyVim.ui.fg("Statement"),
          },
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            --color = LazyVim.ui.fg("Constant"),
          },
          -- stylua: ignore
          --{
          --  function() return "  " .. require("dap").status() end,
          --  cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          --  color = LazyVim.ui.fg("Debug"),
          --},
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            --color = LazyVim.ui.fg("Special"),
          },
          {
            "diff",
            symbols = {
              --added = icons.git.added,
              --modified = icons.git.modified,
              --removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          {
            function()
              return " " .. os.date("%R")
            end,
            separator = { right = "" },
            left_padding = 2,
          },
        },
      },
    }
  end,
}
