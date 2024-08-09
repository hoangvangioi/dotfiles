return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- Ensure C/C++ and python debugger is installed
			{
				"williamboman/mason.nvim",
				optional = true,
				opts = function(_, opts)
					if type(opts.ensure_installed) == "table" then
						vim.list_extend(opts.ensure_installed, { "codelldb", "cpptools", "debugpy" })
					end
				end,
			},
			-- fancy debug ui
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
                -- stylua: ignore
                keys = {
                    { "<leader>du", function() require("dapui").toggle({}) end,  desc = "Dap UI" },
                    { "<leader>de", function() require("dapui").eval() end,      desc = "Eval",  mode = { "n", "v" } },
                },
				opts = {},
				config = function(_, opts)
					local dap = require("dap")
					local dapui = require("dapui")
					dapui.setup(opts)
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open({})
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close({})
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close({})
					end
				end,
			},
			-- Virtual text for the debugger
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},
		keys = {
			{
				"<up>",
				function()
					require("dap").continue()
				end,
				mode = "n",
				desc = "Continue",
			},
			{
				"<down>",
				function()
					require("dap").step_over()
				end,
				mode = "n",
				desc = "Step over",
			},
			{
				"<right>",
				function()
					require("dap").step_into()
				end,
				mode = "n",
				desc = "Step into",
			},
			{
				"<left>",
				function()
					require("dap").step_out()
				end,
				mode = "n",
				desc = "Step out",
			},
			{
				"<Leader>dd",
				function()
					require("dap").toggle_breakpoint()
				end,
				mode = "n",
				desc = "Toggle breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},
			{
				"<leader>dC",
				function()
					require("dap").clear_breakpoints()
				end,
				desc = "Clear breakpoint",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<Leader>dr",
				function()
					require("dap").restart()
				end,
				mode = "n",
				desc = "Restart",
			},
			{
				"<Leader>do",
				function()
					require("dap").repl.toggle()
				end,
				mode = "n",
				desc = "Toggle REPL",
			},
			{
				"<Leader>dl",
				function()
					require("dap").run_last()
				end,
				mode = "n",
				desc = "Run last",
			},
			{
				"<leader>dp",
				function()
					require("dap").pause()
				end,
				desc = "Pause",
			},
			{
				"<Leader>dw",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.frames)
				end,
				mode = "n",
				desc = "debug centered float",
			},
			{
				"<Leader>ds",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.scopes)
				end,
				mode = "n",
				desc = "debug centered_float scopes",
			},
		},

		opts = function()
			local dap = require("dap")
			if not dap.adapters["codelldb"] then
				require("dap").adapters["codelldb"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "codelldb",
						args = {
							"--port",
							"${port}",
						},
					},
				}
			end
			for _, lang in ipairs({ "c", "cpp" }) do
				dap.configurations[lang] = {
					{
						type = "codelldb",
						request = "launch",
						name = "Launch file",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
					},
					{
						type = "codelldb",
						request = "attach",
						name = "Attach to process",
						pid = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
				}
			end
		end,
	},
}
