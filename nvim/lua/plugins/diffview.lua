return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
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
        local is_diff = function()
          local current_tab = vim.api.nvim_get_current_tabpage()
          local windows_in_tab = vim.api.nvim_tabpage_list_wins(current_tab)

          if #windows_in_tab == 0 then
            return false -- No windows in the tab
          end

          for _, win_id in ipairs(windows_in_tab) do
            if vim.wo[win_id].diff then
              --if not vim.api.nvim_win_get_option(win_id, "diff") then
              return true -- Found a window not in diff mode
            end
          end
          return false
        end

        if is_diff() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
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
