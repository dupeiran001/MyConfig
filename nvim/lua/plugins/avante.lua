-- Configuration for avante.nvim plugin
return {
  "yetone/avante.nvim",
  -- Build from source: run `make BUILD_FROM_SOURCE=true`
  -- ⚠️ This setting is required!
  build = function()
    -- conditionally use the correct build system for the current OS
    if vim.fn.has("win32") == 1 then
      return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    else
      return "make"
    end
  end,
  event = "VeryLazy",
  version = false, -- Do not set this value to "*"
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- Add any additional options here
    -- Example configuration
    provider = "gemini",
    providers = {
      ollama = {
        endpoint = "http://llm.a322b:11434",
        --model = 'qwen2.5-coder:32b',
        -- model = 'deepseek-coder-v2:16b',
        --model = 'devstral:24b'
        model = "gpt-oss:120b",
      },
      gemini = {
        model = "gemini-2.5-pro",
      },
    },
    mode = "agentic",
    --mode = "legacy",
    file_selector = {
      provider = "fzf",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- The following dependencies are optional:
    "ibhagwan/fzf-lua",          -- for file_selector provider fzf
    "stevearc/dressing.nvim",    -- for input provider dressing
    "folke/snacks.nvim",         -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    {
      -- Support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
  },
}
