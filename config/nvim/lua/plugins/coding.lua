return {
	-- snippets
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		build = (not LazyVim.is_win())
				and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
			or nil,
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
        -- stylua: ignore
        keys = {
            {
                "<tab>",
                function()
                    return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
                end,
                expr = true,
                silent = true,
                mode = "i",
            },
            { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
            { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
		config = function()
			require("luasnip.loaders.from_snipmate").lazy_load()
		end,
	},

	-- auto completion
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function(_, opts)
			local cmp = require("cmp")

			table.insert(opts.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))

			return {
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<c-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<c-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<S-CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				formatting = {
					format = function(entry, item)
						local icons = LazyVim.config.icons.kinds
						if icons[item.kind] then
							item.kind = icons[item.kind] .. item.kind
						end

						local widths = {
							abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
							menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
						}

						for key, width in pairs(widths) do
							if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
								item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
							end
						end

						return item
					end,
				},
				experimental = {
					ghost_text = {
						hl_group = "LspCodeLens",
					},
				},
			}
		end,
	},

	-- auto pairs
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {},
	},

	-- comments
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {},
	},

	-- surround
	{
		"tpope/vim-surround",
		event = "VeryLazy",
		config = function() end,
	},

	-- Annotations generator
	{
		"danymat/neogen",
		cmd = "Neogen",
		keys = {
			{
				"<leader>cn",
				function()
					require("neogen").generate()
				end,
				desc = "Generate Annotations (Neogen)",
			},
		},
		opts = function(_, opts)
			opts.snippet_engine = "luasnip"
		end,
	},

	-- multi cursor
	-- 1. select words with Ctrl-n
	-- 2. create cursors vertically with Ctrl-Down/Ctrl-Up
	-- 3. select one character at a time with Shift-Arrows
	-- 4. press "n" or "N" to get next/previous occurrence
	-- 5. press "[" or "]" to select next/previous cursor
	-- 6. press "q" or "Q" to skip and remove current and get next/previous occurrence
	-- 7. start insert mode with i,a,I,A
	{
		"mg979/vim-visual-multi",
		event = "VeryLazy",
	},

	-- enhance dot(.)
	{
		"tpope/vim-repeat",
		event = "VeryLazy",
	},

	-- auto remove highlight serach
	{
		"asiryk/auto-hlsearch.nvim",
		event = "VeryLazy",
		config = function()
			require("auto-hlsearch").setup()
		end,
	},
}
