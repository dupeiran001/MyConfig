return {
   'akinsho/bufferline.nvim',
   dependencies = {
      'nvim-tree/nvim-web-devicons',
   },
   lazy = false,
   keys = {
	   {"<leader>b<S-l>", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all left buffers"},
	   {"<leader>b<S-r>", "<cmd>BufferLineCloseRight<cr>", desc = "Close all right buffers"},
	   {"<leader>bl", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer to left"},
	   {"<leader>br", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer to right"},
	   {"<leader>bd", "<cmd>bdelete<cr>", desc = "Delete current buffer"},
	   {"<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Bufferline cycle prev"},
	   {"<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Bufferline cycle next"},
      {"<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Buffer pinning"},
	   {"<leader>1", function() require("bufferline").go_to(1, true) end, desc = "goto Buffer 1"},
	   {"<leader>2", function() require("bufferline").go_to(2, true) end, desc = "goto Buffer 2"},
	   {"<leader>3", function() require("bufferline").go_to(3, true) end, desc = "goto Buffer 3"},
	   {"<leader>4", function() require("bufferline").go_to(4, true) end, desc = "goto Buffer 4"},
	   {"<leader>5", function() require("bufferline").go_to(5, true) end, desc = "goto Buffer 5"},
	   {"<leader>6", function() require("bufferline").go_to(6, true) end, desc = "goto Buffer 6"},
	   {"<leader>7", function() require("bufferline").go_to(7, true) end, desc = "goto Buffer 7"},
	   {"<leader>8", function() require("bufferline").go_to(8, true) end, desc = "goto Buffer 8"},
	   {"<leader>9", function() require("bufferline").go_to(9, true) end, desc = "goto Buffer 9"},
   },
   opts = {
      options = {

         themable = true,
         indicator = {
             icon = '▎',
            style = 'icon'
         },
         diagnostics = "nvim_lsp",
         diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
          end,
         show_buffer_close_icons = false,
         offsets = {
            {
               filetype = "neo-tree",
               text = "Neo-Tree",
               text_align = 'left',
               separator = false,
            }
         },
         numbers = function(opts)
            return string.format('%s', opts.ordinal)
         end,
         show_tab_indicator = true,
         show_duplicate_prefix = true,
         separator_style = "none",
         always_show_bufferline = true,
         auto_toggle_bufferline = true,
         sort_by = 'insert_after_current',
      },
      highlights = {
         fill = { bg = "#2e3440" },
      background = { bg = "#2e3440" },

      tab = { bg = "#2e3440" },
      tab_selected = { bg = "#2e3440" },
      tab_close = { bg = "#2e3440" },

      tab_separator = { bg = "#2e3440", fg = "#4C566A" },
      tab_separator_selected = { bg = "#2e3440", fg = "#81a1c1" },

      close_button = { bg = "#2e3440" },
      close_button_visible = { bg = "#2e3440" },
      close_button_selected = { bg = "#2e3440" },

      buffer = { bg = "#2e3440" },
      buffer_visible = { bg = "#2e3440" },
      buffer_selected = { bg = "#2e3440" },

      numbers = { bg = "#2e3440" },
      numbers_visible = { bg = "#2e3440" },
      numbers_selected = { bg = "#2e3440" },

      diagnostic = { bg = "#2e3440" },
      diagnostic_visible = { bg = "#2e3440" },
      diagnostic_selected = { bg = "#2e3440" },

      hint = { bg = "#2e3440" },
      hint_visible = { bg = "#2e3440" },
      hint_selected = { bg = "#2e3440" },

      hint_diagnostic = { bg = "#2e3440" },
      hint_diagnostic_visible = { bg = "#2e3440" },
      hint_diagnostic_selected = { bg = "#2e3440" },

      info = { bg = "#2e3440" },
      info_visible = { bg = "#2e3440" },
      info_selected = { bg = "#2e3440" },

      info_diagnostic = { bg = "#2e3440" },
      info_diagnostic_visible = { bg = "#2e3440" },
      info_diagnostic_selected = { bg = "#2e3440" },

      warning = { bg = "#2e3440" },
      warning_visible = { bg = "#2e3440" },
      warning_selected = { bg = "#2e3440" },

      warning_diagnostic = { bg = "#2e3440" },
      warning_diagnostic_visible = { bg = "#2e3440" },
      warning_diagnostic_selected = { bg = "#2e3440" },

      error = { bg = "#2e3440" },
      error_visible = { bg = "#2e3440" },
      error_selected = { bg = "#2e3440" },

      error_diagnostic = { bg = "#2e3440" },
      error_diagnostic_visible = { bg = "#2e3440" },
      error_diagnostic_selected = { bg = "#2e3440" },

      duplicate = { bg = "#2e3440" },
      duplicate_visible = { bg = "#2e3440" },
      duplicate_selected = { bg = "#2e3440" },

      separator = { bg = "#2e3440", fg = "#4C566A" },
      separator_selected = { bg = "#2e3440" },
      separator_visible = { bg = "#2e3440" },

      modified = { bg = "#2e3440" },
      modified_visible = { bg = "#2e3440" },
      modified_selected = { bg = "#2e3440" },

      indicator_selected = { bg = "#2e3440" },
      indicator_visible = { bg = "#2e3440" },

      pick = { bg = "#2e3440" },
      pick_visible = { bg = "#2e3440" },
      pick_selected = { bg = "#2e3440" },

      offset_separator = { bg = "#2e3440" },

      trunc_marker = { bg = "#2e3440" },

      }
   }
}