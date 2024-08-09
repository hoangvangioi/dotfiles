return {
	{
		"nvim-tree/nvim-tree.lua",
		keys = {
			{
				"<leader>e",
				"<cmd>NvimTreeToggle<cr><cmd>IlluminatePauseBuf<cr>",
				silent = true,
				desc = "Explorer NeoTree",
			},
		},
		opts = {
			sort_by = "case_sensitive",
			hijack_cursor = true,
			view = {
				width = 25,
			},
			renderer = {
				group_empty = true,
				highlight_git = true,
				icons = {
					glyphs = {
						git = {
							unstaged = "",
							staged = "",
							unmerged = "",
							renamed = "",
							deleted = "",
							untracked = "",
							ignored = "",
						},
						folder = {
							default = "",
							open = "",
							symlink = "",
						},
					},
					show = {
						git = false,
						file = true,
						folder = true,
						folder_arrow = false,
					},
				},
			},
			filters = {
				dotfiles = true,
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")

				local function opts(desc)
					return {
						desc = "nvim-tree: " .. desc,
						buffer = bufnr,
						noremap = true,
						silent = true,
						nowait = true,
					}
				end

				-- file operation
				vim.keymap.set("n", "<leader>", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "<cr>", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "<bs>", api.node.navigate.parent_close, opts("Close Directory"))
				vim.keymap.set("n", "q", api.tree.close, opts("Close"))
				vim.keymap.set("n", "a", api.fs.create, opts("Create"))
				vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
				vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
				vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
				vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
				vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
				-- items
				vim.keymap.set("n", "f", api.live_filter.start, opts("Filter"))
				vim.keymap.set("n", "F", api.live_filter.clear, opts("Clean Filter"))
				vim.keymap.set("n", "e", api.tree.expand_all, opts("Expand All"))
				vim.keymap.set("n", "w", api.tree.collapse_all, opts("Collapse"))
				vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
				vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
				-- modfied file in git
				vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
				vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
				-- opne with tab/split
				vim.keymap.set("n", "<tab>", api.node.open.tab, opts("Open: New Tab"))
				vim.keymap.set("n", "<C-s>", api.node.open.vertical, opts("Open: Vertical Split"))
				vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
				-- copy path
				vim.keymap.set("n", "y", api.fs.copy.relative_path, opts("Copy Relative Path"))
				vim.keymap.set("n", "Y", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
				-- help
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
			end,
		},
		config = function(_, opts)
			-- disable netrw at the very start of your init.lua
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			-- set termguicolors to enable highlight groups
			vim.opt.termguicolors = true
			require("nvim-tree").setup(opts)
		end,
	},
}
