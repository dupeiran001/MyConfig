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
    servers = {
      yamlls = {
        settings = {
          yaml = {
            format = {
              enable = true,
            },
          },
        },
      },
    },
  },
}
