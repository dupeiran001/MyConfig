return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
    "ibhagwan/fzf-lua",
  },
  cmd = {
    "DiffviewClose",
    "DiffviewOpen",
    "DiffviewFileHistory",
    "DiffviewFocusFiles",
    "DiffviewLog",
    "DiffviewRefresh",
    "DiffviewToggleFiles",
  },
  keys = {
    {
      "<leader>dd",
      function()
        local lib = require 'diffview.lib'
        local view = lib.get_current_view()
        if view then
          -- Current tabpage is a Diffview; close it
          vim.cmd(":DiffviewClose")
        else
          -- No open Diffview exists: open a new one
          vim.cmd(":DiffviewOpen")
        end
      end,
      desc = "Toggle Diffview",
    },
    {
      "<leader>df",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "Diffview Current File History"
    },
    {
      "<leader>dF",
      function()
        local fzf_lua = require("fzf-lua")
        fzf_lua.fzf_exec("find . -type f", {
          prompt = "Pick file> ",
          previewer = false,
          preview = {
            type = 'cmd',
            fn = function(item)
              -- `item.path` contains the clean, absolute file path
              local filename = item[1]
              if not filename then return "" end

              -- Escape the filename for safe use in a shell command
              local escaped_filename = vim.fn.shellescape(filename)

              -- Create a sequence of shell commands. The output of all of them
              -- will be shown together in the preview window.
              return table.concat({
                "echo ' Git History'",
                "git log --pretty=format:'%C(yellow)%ad%C(reset) %C(green)%h%C(reset) %s' --date=short --color=always -n 10 -- " ..
                escaped_filename,
                "echo ' '", -- Adds a blank line for spacing
                "echo ' File Content'",
                "bat --style=numbers --color=always --line-range=:100 " .. escaped_filename,
              }, " && ")
            end,
          },
          actions = {
            ['default'] = function(selected)
              if selected and selected[1] then
                local file = vim.fn.fnamemodify(selected[1], ":p")
                vim.cmd("DiffviewFileHistory " .. file)
              end
            end
          }
        })
      end,
      desc = "Diffview Current File History"
    }
  },
  opts = {
    hooks = {
      diff_buf_read = function(bufnr)
        -- Change local options in diff buffers
        vim.opt_local.wrap = false
        vim.opt_local.list = false
        vim.opt_local.colorcolumn = { 80 }
      end,
      diff_buf_win_enter = function(bufnr, winid, ctx)
        -- Turn off cursor line for diffview windows because of bg conflict
        -- https://github.com/neovim/neovim/issues/9800
        vim.wo[winid].culopt = "number"
      end,
    },
  },
}
