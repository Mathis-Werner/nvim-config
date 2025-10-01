-- options
---------------------------------------------

--- Tabstops
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- Set leaderkey
vim.g.mapleader= " "

-- Realitve and absolute line numbers
vim.opt.number = true
--vim.opt.relativenumber = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Add noselect to completeopt
vim.cmd("set completeopt+=noselect")

-- Enable rounded borders in floating windows
vim.o.winborder = 'rounded'
