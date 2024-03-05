return {
  "ahmedkhalf/project.nvim",
  keys = {
    { "<leader>p", "<Cmd>ProjectRoot<CR>", desc = "Projects" },
  },
  opts = {
     -- Manual mode doesn't automatically change your root directory, so you have
     -- the option to manually do so using `:ProjectRoot` command.
     manual_mode = true,

     -- When set to false, you will get a message when project.nvim changes your
     -- directory.
     silent_chdir = false,

     -- What scope to change the directory, valid options are
     -- * global (default)
     -- * tab
     -- * win
     scope_chdir = 'global',

     -- Path where project.nvim will store the project history for use in
     -- telescope
     datapath = vim.fn.stdpath("data"),
  }
}
