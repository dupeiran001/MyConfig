local opts = { noremap = true, silent = false }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Tab between windows
keymap("n", "<Tab>", "<C-w>w", opts)

-- Close Window
keymap("n", "<leader>q", "<cmd>close<cr>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<S-h>", "<gv", opts)
keymap("v", "<S-l>", ">gv", opts)

-- Move text up and down
keymap("v", "<S-j>", ":m .+1<CR>==", opts)
keymap("v", "<S-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Easy creation of a terminal

keymap("n", "<C-\\>", "<cmd>ToggleTerm<cr>", opts)

-- Better terminal navigation
keymap("t", "<C-h>", "<C-c><C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

keymap('t', '<esc>', "<C-\\><C-N>", opts)
keymap('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)

keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>fc", "<cmd>Telescope live_grep<cr>", opts)
keymap('n', "<leader>fp", "<cmd>Telescope projects<cr>", opts)

-- split window
keymap("n", "<leader>ss", "<cmd>split<cr>", opts)
keymap("n", "<leader>sv", "<cmd>vsplit<cr>", opts)
keymap("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", opts)
keymap("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", opts)
keymap("n", "<leader>bf", "<cmd>BufferLinePick<cr>", opts)
keymap("n", "<leader>bd", "<cmd>Bdelete<cr>", opts)
