return {
  "ibhagwan/fzf-lua",
  lazy = true,
  cmd = "FzfLua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "tomasky/bookmarks.nvim",
    "folke/todo-comments.nvim",
  },
  keys = {
    { "<leader>ff",  "<cmd>FzfLua files<cr>",                 desc = "Find files" },
    { "<leader>fh",  "<cmd>FzfLua files cwd=~<cr>",           desc = "Find files (HOME)" },
    { "<leader>fc",  "<cmd>FzfLua live_grep<cr>",             desc = "LiveGrep" },
    { "<leader>fC",  "<cmd>FzfLua changes<cr>",               desc = "Changes" },
    { "<leader>fb",  "<cmd>FzfLua buffers<cr>",               desc = "Buffers" },
    { "<leader>fgc", "<cmd>FzfLua git_commits<cr>",           desc = "Git Commits" },
    { "<leader>fgb", "<cmd>FzfLua git_branches<cr>",          desc = "Git Branches" },
    { "<leader>fgs", "<cmd>FzfLua git_status<cr>",            desc = "Git Status" },
    { "<leader>fo",  "<cmd>FzfLua oldfiles<cr>",              desc = "Recent files" },
    { "<leader>fr",  function() require('neoclip.fzf')() end, desc = "Fzf neoclip history" },
    { "<leader>fR",  "<cmd>FzfLua resume<cr>",                desc = "Resume" },
    { "<leader>fB",  "<cmd>FzfLua builtin<cr>",               desc = "Builtin" },
    { "<leader>ft",  "<cmd>FzfLua tabs<cr>",                  desc = "Tabs" },
    { "<leader>fT",  "<cmd>TodoFzfLua<cr>",                   desc = "Todos" },
    { "<leader>fd",  "<cmd>FzfLua lsp_document_symbols<cr>",  desc = "Document Symbols" },
    { "<leader>fw",  "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
    {
      "<leader>fm",
      function()
        _G.fzf_marks()
      end,
      desc = "Bookmarks",
    },

    { "<leader>ca", "<cmd>FzfLua lsp_code_actions previewer=codeaction_native<cr>", desc = "Code Action" },
  },
  opts = {
    winopts = {
      treesitter = {
        enable = true,
      },
    },
    on_create = function()
      vim.keymap.del("t", "<C-j>", { buffer = 0 })
      vim.keymap.del("t", "<C-k>", { buffer = 0 })
      vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, noremap = true, buffer = true })
      vim.keymap.set("t", "<C-k>", "<Up>", { silent = true, no_remap = true, buffer = true })
    end,
    fzf_colors = true,
  },
  init = function()
    _G.fzf_marks = function(opts)
      local fzf_lua = require("fzf-lua")
      local bookmark_config = require("bookmarks.config").config
      local builtin = require("fzf-lua.previewer.builtin")
      local utils = require("fzf-lua.utils")

      local function get_text(annotation)
        local pref = string.sub(annotation, 1, 2)
        local ret = bookmark_config.keywords[pref]
        if ret == nil then
          ret = bookmark_config.signs.ann.text .. " "
        end
        return ret .. annotation
      end

      local function build_marklist()
        local allmarks = bookmark_config.cache.data
        local marklist = {}
        for filename, marks in pairs(allmarks) do
          for lnum, v in pairs(marks) do
            table.insert(marklist, {
              filename = filename,
              lnum = tonumber(lnum),
              text = v.a and get_text(v.a) or v.m,
            })
          end
        end
        return marklist
      end

      opts = opts or {}
      opts.prompt = "Marks> "

      local marklist = build_marklist()

      local function contents(callback)
        for _, mark in ipairs(marklist) do
          local entry = string.format(
            "%s%s %s",
            utils.ansi_codes.magenta(mark.filename),
            utils.ansi_codes.green(":" .. tostring(mark.lnum) .. ":"),
            mark.text
          )
          callback(entry)
        end
        callback(nil) -- Signals the end of data
      end

      local MyPreviewer = builtin.buffer_or_file:extend()

      function MyPreviewer:new(o, opts_n, fzf_win)
        MyPreviewer.super.new(self, o, opts_n, fzf_win)
        setmetatable(self, MyPreviewer)
        return self
      end

      function MyPreviewer:parse_entry(entry_str)
        local path, line = entry_str:match("^(.*):(%d+):")
        -- local _, path, line = entry_str:match("^(%S+)%s+(.*):(%d+):")
        return {
          path = path,
          line = tonumber(line) or 1,
          col = 1,
        }
      end

      fzf_lua.fzf_exec(contents, {
        prompt = opts.prompt,
        previewer = MyPreviewer,
        actions = {
          ["default"] = function(selected)
            local filename, lnum = selected[1]:match("^(.*):(%d+):")
            -- local _, filename, lnum = selected[1]:match("^(%S+)%s+(.*):(%d+):")
            if filename and lnum then
              vim.cmd(string.format("edit +%d %s", lnum, filename))
            end
          end,
          ["ctrl-x"] = function(_)
            require("bookmarks").bookmark_clear_all()
          end,
        },
        header = { ":: <ctrl-x> to clear all marks" },
      })
    end
  end,
}
