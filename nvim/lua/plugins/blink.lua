return {
  "saghen/blink.cmp",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- optional: provides snippets for the snippet source
    "rafamadriz/friendly-snippets",
    "brenoprata10/nvim-highlight-colors",
    "xzbdmw/colorful-menu.nvim",
    -- "giuxtaposition/blink-cmp-copilot",
    -- "fang2hou/blink-copilot",
    -- "zbirenbaum/copilot.lua", -- for providers='copilot'
    'Kaiser-Yang/blink-cmp-avante',
    'milanglacier/minuet-ai.nvim'
  },

  -- use a release tag to download pre-built binaries
  version = "*",
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',


  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = {
      preset = "none",
      ["<C-j>"] = { "select_next", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<cr>"] = { "accept", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-Down>"] = { "scroll_documentation_down", "fallback" },
      ["<C-Up>"] = { "scroll_documentation_up", "fallback" },
      ["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active then
            return cmp.accept()
          end
        end,
        "snippet_forward",
        "fallback",
      },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
      kind_icons = {
        Copilot = "",
        Text = "󰉿",
        Method = "󰊕",
        Function = "󰊕",
        Constructor = "󰒓",

        Field = "󰜢",
        Variable = "󰆦",
        Property = "󰖷",

        Class = "󱡠",
        Interface = "󱡠",
        Struct = "󱡠",
        Module = "󰅩",

        Unit = "󰪚",
        Value = "󰦨",
        Enum = "󰦨",
        EnumMember = "󰦨",

        Keyword = "󰻾",
        Constant = "󰏿",

        Snippet = "󱄽",
        Color = "󰏘",
        File = "󰈔",
        Reference = "󰬲",
        Folder = "󰉋",
        Event = "󱐋",
        Operator = "󰪚",
        TypeParameter = "󰬛",

        Ollama = '󰳆',
      },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      -- add lazydev to your completion providers
      default = { "avante", "minuet", "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        avante = {
          module = 'blink-cmp-avante',
          name = 'Avante',
        },
        minuet = {
          name = 'minuet',
          module = 'minuet.blink',
          async = true,
          -- Should match minuet.config.request_timeout * 1000,
          -- since minuet.config.request_timeout is in seconds
          timeout_ms = 10000,
          score_offset = 50, -- Gives minuet higher priority among suggestions
        },
      },
    },

    completion = {
      trigger = {
        show_on_keyword = true,
        prefetch_on_insert = true,
      },
      list = {
        selection = { preselect = false, auto_insert = false },
        -- selection = 'manual',
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
      menu = {
        auto_show = true,
        draw = {

          -- We don't need label_description now because label and label_description are already
          -- conbined together in label by colorful-menu.nvim.
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            label = {
              width = { fill = true, max = 60 },
              text = function(ctx)
                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                if highlights_info ~= nil then
                  -- Or you want to add more item to label
                  return highlights_info.label
                else
                  return ctx.label
                end
              end,
              highlight = function(ctx)
                local highlights = {}
                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                if highlights_info ~= nil then
                  highlights = highlights_info.highlights
                end
                for _, idx in ipairs(ctx.label_matched_indices) do
                  table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                end
                -- Do something else
                return highlights
              end,
            },
          },
          -- customize the drawing of kind icons
          --kind_icon = {
          --  text = function(ctx)
          --    -- default kind icon
          --    local icon = ctx.kind_icon
          --    -- if LSP source, check for color derived from documentation
          --    if ctx.item.source_name == "LSP" then
          --      local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
          --      if color_item and color_item.abbr then
          --        icon = color_item.abbr
          --      end
          --    end
          --    return icon .. ctx.icon_gap
          --  end,
          --  highlight = function(ctx)
          --    -- default highlight group
          --    local highlight = "BlinkCmpKind" .. ctx.kind
          --    -- if LSP source, check for color derived from documentation
          --    if ctx.item.source_name == "LSP" then
          --      local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
          --      if color_item and color_item.abbr_hl_group then
          --        highlight = color_item.abbr_hl_group
          --      end
          --    end
          --    return highlight
          --  end,
          --},
        },
      },
    },
    signature = { enabled = true },
  },

  opts_extend = { "sources.default" },
}
