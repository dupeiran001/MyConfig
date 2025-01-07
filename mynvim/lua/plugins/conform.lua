return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cF",
      function()
        if vim.g.disable_autoformat then
          vim.notify("Auto Format Enabled")
        else
          vim.notify("Auto Format Disabled")
        end
        vim.g.disable_autoformat = not vim.g.disable_autoformat
      end,
      desc = "Auto Format"
    },
    {
      "<leader>cf",
      function()
        require('conform').format({ lsp_format = "fallback" })
      end,
      desc = "Format File"
    }
  },
  opts = {
    -- formatters_by_ft = {
    --   lua = { "stylua" },
    --   -- Conform will run multiple formatters sequentially
    --   python = { "isort", "black" },
    --   -- You can customize some of the format options for the filetype (:help conform.format)
    --   rust = { "rustfmt", lsp_format = "fallback" },
    --   -- Conform will run the first available formatter
    --   javascript = { "prettierd", "prettier", stop_after_first = true },
    -- },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 2000, lsp_format = "fallback" }
    end
  },
  config = function(_, opts)
    local conform = require('conform')

    conform.setup(opts)
  end
}
