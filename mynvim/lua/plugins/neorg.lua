return {
  "nvim-neorg/neorg",
  dependencies = {
    'benlubas/neorg-interim-ls',
    'saghen/blink.cmp',
  },
  lazy = true, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  ft = "norg",
  cmd = "Neorg",
  version = "*", -- Pin Neorg to the latest stable release
  opts = {
    load = {
      ["core.defaults"] = {},
      ["core.concealer"] = {
        config = {
          icon_preset = "diamond",
          icons = {
            heading = {
              highlights = {
                "@neorg.headings.n.1.prefix",
                "@neorg.headings.n.2.prefix",
                "@neorg.headings.n.3.prefix",
                "@neorg.headings.n.4.prefix",
                "@neorg.headings.n.5.prefix",
                "@neorg.headings.n.6.prefix"
              },
            }
          }
        }
      },
      ['core.esupports.metagen'] = {
        config = {
          author = "Peiran Du",
          type = "auto",
        }
      },
      ['core.export'] = {},
      ['core.latex.renderer'] = {
        config = {
          conceal = true,
          render_on_enter = true,
        }
      },
      ["core.highlights"] = {
        config = {
          highlights = {
            headings = {
              ["1"] = {
                title = "+@neorg.headings.n.1.title",
                prefix = "+@neorg.headings.n.1.prefix",
              },

              ["2"] = {
                title = "+@neorg.headings.n.2.title",
                prefix = "+@neorg.headings.n.2.prefix",
              },

              ["3"] = {
                title = "+@neorg.headings.n.3.title",
                prefix = "+@neorg.headings.n.3.prefix",
              },

              ["4"] = {
                title = "+@neorg.headings.n.4.title",
                prefix = "+@neorg.headings.n.4.prefix",
              },

              ["5"] = {
                title = "+@neorg.headings.n.5.title",
                prefix = "+@neorg.headings.n.5.prefix",
              },

              ["6"] = {
                title = "+@neorg.headings.n.6.title",
                prefix = "+@neorg.headings.n.6.prefix",
              },
            }
          }
        }
      },
      ["core.dirman"] = {
        config = {
          workspaces = {
            document = "~/Documents/document/",
          },
          default_workspace = "document",
        },
      },
      ["core.keybinds"] = {
        config = {
          default_keybinds = true,
        },
      },
      ["core.completion"] = {
        config = { engine = { module_name = "external.lsp-completion" } },
      },
      ["external.interim-ls"] = {
        config = {
          -- default config shown
          completion_provider = {
            -- Enable or disable the completion provider
            enable = true,

            -- Show file contents as documentation when you complete a file name
            documentation = true,

            -- Try to complete categories provided by Neorg Query. Requires `benlubas/neorg-query`
            categories = false,

            -- suggest heading completions from the given file for `{@x|}` where `|` is your cursor
            -- and `x` is an alphanumeric character. `{@name}` expands to `[name]{:$/people:# name}`
            people = {
              enable = false,

              -- path to the file you're like to use with the `{@x` syntax, relative to the
              -- workspace root, without the `.norg` at the end.
              -- ie. `folder/people` results in searching `$/folder/people.norg` for headings.
              -- Note that this will change with your workspace, so it fails silently if the file
              -- doesn't exist
              path = "people",
            }
          }
        }
      },
    },
  },
  config = function(_, opts)
    require('neorg').setup(opts)

    -- vim.api.nvim_set_hl(0, "@neorg.headings.1.prefix", { fg = "#BF616A" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.1.title", { fg = "#BF616A" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.2.prefix", { fg = "#D08770" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.2.title", { fg = "#D08770" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.3.prefix", { fg = "#EBCB8B" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.3.title", { fg = "#EBCB8B" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.4.prefix", { fg = "#A3BE8C" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.4.title", { fg = "#A3BE8C" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.5.prefix", { fg = "#B48EAD" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.5.title", { fg = "#B48EAD" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.6.prefix", { fg = "#81A1C1" })
    -- vim.api.nvim_set_hl(0, "@neorg.headings.6.title", { fg = "#81A1C1" })
  end
}
