local M = {}

M.exec_django_code = function(code)
	-- execute the django code and return the result
	return code
end

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("n", "<space>tr", function()
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
	vim.keymap.set("n", "<space>tb", function()
		vim.cmd.vnew()
		vim.cmd.term()
		vim.cmd.wincmd("J")
		vim.api.nvim_win_set_height(0, 10)

		local job_id = vim.bo.channel

		vim.fn.chansend(job_id, {
			"python 'C:\\Users\\shahr\\Music\\4 - Django\\rh\\src\\manage.py' shell --command \"print('hello from django')\" \r\n",
		})
	end)
end

return M
