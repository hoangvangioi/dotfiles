-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.encoding = "utf-8"
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.wildmenu = true
opt.showcmd = true
opt.wrap = true
opt.cursorline = true -- Enable highlighting of the current line

-- tab
opt.autoindent = true
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

opt.scrolloff = 6 -- Lines of context

opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals

opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers

opt.list = true -- Show some invisible characters (tabs...
-- opt.listchars:append "space:·" -- Show space
opt.showmode = false -- Dont show mode since we have a statusline
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.confirm = true -- Confirm to save changes before exiting modified buffer

opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.completeopt = "menu,menuone,noselect"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 0
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shortmess:append({ W = true, I = true, c = true })
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.termguicolors = true -- True color support
opt.guicursor = "" -- user fat cursor in the insert mode
opt.timeoutlen = 300
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.splitkeep = "screen"

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
