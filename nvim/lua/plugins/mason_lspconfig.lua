return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    -- "williamboman/mason-lspconfig.nvim", -- This is the main plugin, no need to list as its own dependency
    "saghen/blink.cmp",
  },
  event = { "BufReadPre", "BufNewFile" },
  lazy = true,
  opts = {
    -- A list of servers to automatically install if they're not already installed.
    ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "bashls", "cmake", "marksman", "pyright", "taplo" },

    -- Whether servers that are set up (via lspconfig) should be automatically installed.
    automatic_installation = false,     -- Can be true or { exclude = { ... } }

    -- Handlers definition now directly part of opts
    handlers = {
      -- This first function is the default handler and will be called for each installed server
      -- that doesn't have a dedicated handler.
      function(server_name)       -- Default handler
        local lspconfig = require("lspconfig")
        local capabilities = require("blink.cmp").get_lsp_capabilities()
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,

      -- Dedicated handler for lua_ls
      ["lua_ls"] = function()
        local lspconfig = require("lspconfig")
        local capabilities = require("blink.cmp").get_lsp_capabilities()
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          on_init = function(client)
            -- Check if workspace_folders is not nil and has at least one entry
            if client.workspace_folders and client.workspace_folders[1] and client.workspace_folders[1].name then
              local path = client.workspace_folders[1].name
              if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
                return
              end
            end
            -- Ensure client.config.settings.Lua exists before trying to extend it
            client.config.settings = client.config.settings or {}
            client.config.settings.Lua = client.config.settings.Lua or {}

            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
              runtime = {
                version = "LuaJIT",
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                },
              },
            })
          end,
          settings = {
            Lua = {},             -- Initial settings, on_init will modify/extend this
          },
        })
      end,

      -- Example: Dedicated handler for rust_analyzer (if you were using rust-tools)
      -- ["rust_analyzer"] = function ()
      --   require("rust-tools").setup {} -- You would need to have rust-tools.nvim installed
      -- end

      -- Add other specific server handlers here, for example:
      -- ["pyright"] = function()
      --   local lspconfig = require("lspconfig")
      --   local capabilities = require("blink.cmp").get_lsp_capabilities()
      --   lspconfig.pyright.setup({
      --     capabilities = capabilities,
      --     settings = {
      --       python = {
      --         analysis = {
      --           typeCheckingMode = "basic", -- or "strict"
      --         }
      --       }
      --     }
      --   })
      -- end,
    },
  },
  config = function(_, opts)
    -- The opts table here is the one defined above, including your handlers.
    -- mason-lspconfig will now use opts.handlers internally.
    require("mason-lspconfig").setup(opts)

    -- You can still add other general LSP configurations here if needed,
    -- for example, global mappings for LSP actions, but server-specific setup
    -- should be within the handlers.
    -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = 0 })
    -- etc.
  end,
}
