return {
	{
		"nvimdev/lspsaga.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-treesitter/nvim-treesitter", -- optional
			"nvim-tree/nvim-web-devicons", -- optional
		},
		opts = {
			-- lsp symbol navigation for lualine
			symbol_in_winbar = {
				enable = true,
				show_file = false,
			},
			outline = {
				win_width = 25,
				keys = {
					toggle_or_jump = "<leader>",
				},
			},
			rename = {
				keys = {
					quit = "<c-c>",
				},
			},
		},
		config = function(_, opts)
			require("lspsaga").setup(opts)
		end,
	},
}
