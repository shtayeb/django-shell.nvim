local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local previewers = require("telescope.previewers")
local tels_prevs_utils = require("telescope.previewers.utils")

local log = require("plenary.log"):new()
log.level = "debug"

local M = {}

M.result_bufnr = -1
M.cwd = vim.fn.getcwd()

local function find_manage_py()
	-- Check if manage.py exists in the current directory
	local manage_py_in_cwd = M.cwd .. "/manage.py"
	if vim.fn.filereadable(manage_py_in_cwd) == 1 then
		return manage_py_in_cwd
	end

	-- Check for manage.py one level down
	local subdirs = vim.fn.glob(M.cwd .. "/*", true, true) -- List all files and directories in cwd
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

M.manage_py_path = find_manage_py()

local function find_python_path()
	local py_path = M.cwd .. "/.venv/bin/python"

	if vim.fn.has("win32") == 1 then
		py_path = M.cwd .. "/.venv/Scripts/python"
	end

	return py_path
end

M.python_path = find_python_path()

M.exec_django_code = function(code)
	local code_str = table.concat(code, ";")
	local cmd = { M.python_path, M.manage_py_path, "shell", "--command", code_str }

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(M.result_bufnr, 0, 0, false, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(M.result_bufnr, 0, 0, false, data)
			end
		end,
	})
end

function M.setup(opts)
	opts = opts or {}

	-- TODO: get the available django commands and display it in a telescope search prompt
	vim.keymap.set("n", "<space>tc", function()
		M.show_django_cmds()
	end)

	vim.keymap.set("n", "<space>tr", function()
		-- the all text in the current buffer till the cursor position
		local curr_buf = vim.api.nvim_get_current_buf()
		local cursor_position = vim.api.nvim_win_get_cursor(0) -- 0 -> current window

		local code = vim.api.nvim_buf_get_lines(curr_buf, 0, cursor_position[1], false)

		if M.result_bufnr == -1 then
			vim.cmd.vnew()
			M.result_bufnr = vim.api.nvim_get_current_buf()
		end

		M.exec_django_code(code)

		tels_prevs_utils.highlighter(M.result_bufnr, "python")
	end)
end

M.show_django_cmds = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_async_job({
				command_generator = function()
					return { M.python_path, M.manage_py_path, "help", "--commands" }
				end,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry,
						ordinal = entry, -- is the sorting and filtering key
					}
				end,
			}),
			sorter = config.generic_sorter(opts),
			previewer = previewers.new_termopen_previewer({
				title = "Command Help",
				get_command = function(entry, _)
					return { M.python_path, M.manage_py_path, "help", entry.value }
				end,
			}),
		})
		:find()
end

return M
