return {
	{
		"dhruvasagar/vim-table-mode",
		cmd = "TableModeToggle",
		keys = { { "<leader>mb", "<cmd>TableModeToggle<cr>", desc = "Toggle markdown table" } },
	},
	-- markdown-preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	-- mdx
	{
		"davidmh/mdx.nvim",
		config = true,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
}
