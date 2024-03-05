return   {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      handler_opts = {
        border = "rounded"
      },
      floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
      floating_window_above_cur_line = true,
    },
    config = function(_, opts)
      require 'lsp_signature'.setup(opts)
    end
  }
