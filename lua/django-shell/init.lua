local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local previewers = require("telescope.previewers")
local tels_prevs_utils = require("telescope.previewers.utils")

local M = {}

M.result_buf = -1

local function find_manage_py(cwd)
	-- local manage_py = vim.fn.findfile("manage.py", cwd .. ";") -- Recursively search
	-- local manage_py = vim.fn.findfile("manage.py", cwd .. "/*")

	-- Check if manage.py exists in the current directory
	local manage_py_in_cwd = cwd .. "/manage.py"
	if vim.fn.filereadable(manage_py_in_cwd) == 1 then
		return manage_py_in_cwd
	end

	-- Check for manage.py one level down
	local subdirs = vim.fn.glob(cwd .. "/*", true, true) -- List all files and directories in cwd
	for _, subdir in ipairs(subdirs) do
		if vim.fn.isdirectory(subdir) == 1 then
			local manage_py_in_subdir = subdir .. "/manage.py"
			if vim.fn.filereadable(manage_py_in_subdir) == 1 then
				return manage_py_in_subdir
			end
		end
	end

	return nil
end

M.exec_django_code = function(cwd, manage_py_path, code)
	local code_str = table.concat(code, ";")

	local cmd = cwd .. "/.venv/bin/python " .. manage_py_path .. " shell --command '" .. code_str .. "'\r\n"

	local result = io.popen(cmd):read("*a")

	os.execute(cmd)

	return result
end

function M.setup(opts)
	opts = opts or {}

	-- TODO: get the available django commands and display it in a telescope search prompt
	vim.keymap.set("n", "<space>tc", function()
		M.show_django_cmds()
	end)

	vim.keymap.set("n", "<space>tr", function()
		-- current working directory
		local cwd = vim.fn.getcwd()
		local manage_py = find_manage_py(cwd)

		-- the all text in the current buffer till the cursor position
		local curr_buf = vim.api.nvim_get_current_buf()
		local cursor_position = vim.api.nvim_win_get_cursor(0) -- 0 -> current window

		local code = vim.api.nvim_buf_get_lines(curr_buf, 0, cursor_position[1], false)

		local result = M.exec_django_code(cwd, manage_py, code)

		-- print(result)
		local winnr = vim.fn.win_findbuf("results")[1]
		if winnr == -1 then
			vim.cmd.vnew("results")
			winnr = vim.fn.winnr()
			M.results_winnr = winnr
			M.results_bufnr = vim.fn.bufnr("results")
		else
			vim.cmd.buffer("results")
			M.results_winnr = winnr
			M.results_bufnr = vim.fn.bufnr("results")
		end

		-- syntax highlight the results
		vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(result, "\n"))
	end)
end

M.show_django_cmds = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_table({
				results = {
					{ name = "Yes", value = { 1, 2, 3 } },
					{ name = "No", value = { -1, -2, -3 } },
				},
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name, -- is the sorting and filtering key
					}
				end,
			}),
			sorter = config.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				title = "Command Help",
				define_preview = function(self, entry)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, false, vim.split(vim.inspect(entry.value), "\n"))
					tels_prevs_utils.highlighter(self.state.bufnr, "python")
				end,
			}),
		})
		:find()
end

return M
