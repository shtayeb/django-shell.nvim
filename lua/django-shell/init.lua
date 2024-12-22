local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local previewers = require("telescope.previewers")
local tels_prevs_utils = require("telescope.previewers.utils")

local M = {}

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

M.exec_django_code = function(code)
	-- execute the django code and return the result
	return code
end

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

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("n", "<space>tr", function()
		-- current working directory
		-- local cwd = vim.fn.getcwd()

		-- the all text in the current buffer till the cursor position
		local curr_buf = vim.api.nvim_get_current_buf()
		local cursor_position = vim.api.nvim_win_get_cursor(0) -- 0 -> current window

		local code = vim.api.nvim_buf_get_lines(curr_buf, 0, cursor_position[1], false)

		-- execute the code and return the result
		-- NOTE: might need to parse the result and split it by \n for nvim_buf_get_lines
		local res = M.exec_django_code(code)

		-- create a new window and put the result there
		vim.cmd.vnew("results")
		-- vim.cmd.wincmd("J")
		-- vim.api.nvim_win_set_height(0, 10)

		-- put the result in the new buffer inside the new window
		-- TODO: Highlight the result
		vim.api.nvim_buf_set_lines(0, 0, 0, false, res)
	end)

	-- TODO: get the available django commands and display it in a telescope search prompt
	vim.keymap.set("n", "<space>tc", function()
		M.show_django_cmds()
	end)

	vim.keymap.set("n", "<space>tb", function()
		-- current working directory
		local cwd = vim.fn.getcwd()
		local manage_py = find_manage_py(cwd)

		-- the all text in the current buffer till the cursor position
		local curr_buf = vim.api.nvim_get_current_buf()
		local cursor_position = vim.api.nvim_win_get_cursor(0) -- 0 -> current window

		local code = vim.api.nvim_buf_get_lines(curr_buf, 0, cursor_position[1], false)
		local code_str = table.concat(code, ";")

		vim.cmd.vnew()
		vim.cmd.term()
		vim.cmd.wincmd("J")
		vim.api.nvim_win_set_height(0, 10)

		local job_id = vim.bo.channel

		vim.fn.chansend(job_id, {
			cwd .. "/.venv/bin/python " .. manage_py .. " shell --command '" .. code_str .. "'\r\n",
		})
	end)
end

return M
