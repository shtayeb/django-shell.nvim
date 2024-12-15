local M = {}

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("n", "<Leader>h", function()
		if opts.name then
			print("Hello, " .. opts.name)
		else
			print("Hello, World!")
		end
	end)
end

return M
