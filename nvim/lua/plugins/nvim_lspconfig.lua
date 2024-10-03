return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = {
        prefix = "icons",
      },
    },
    inlay_hints = {
      enabled = true,
    },
    codelens = {
      enabled = false,
    },
    keys = {
      {
        "gd",
        function()
          require("telescope.builtin").lsp_definitions({ reuse_win = false, jump_type = "split" })
        end,
        desc = "Goto Definition",
        has = "definition",
      },
      {
        "gr",
        "<cmd>Telescope lsp_references<cr>",
        desc = "References",
        nowait = true,
      },
      {
        "gI",
        function()
          require("telescope.builtin").lsp_implementations({ reuse_win = false, jump_type = "split" })
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          require("telescope.builtin").lsp_type_definitions({ reuse_win = false, jump_type = "split" })
        end,
        desc = "Goto T[y]pe Definition",
      },
    },
  },
}
