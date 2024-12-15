local M = {}

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("n","<space>tr",function ()
		vim.cmd.vnew()
		vim.cmd.term()
		vim.cmd.wincmd("J")
		vim.api.nvim_win_set_height(0,10)

		local job_id = vim.bo.channel

		vim.fn.chansend(job_id, {"echo hi \r\n"})
	end)

	vim.keymap.set("n", "<Leader>h", function()
		if opts.name then
			print("Hello, " .. opts.name)
		else
			print("Hello, World!")
		end
	end)
end

return M
