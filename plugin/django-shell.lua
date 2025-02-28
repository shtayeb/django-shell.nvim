vim.api.nvim_create_user_command("DjangoCommands", function()
   require("django-shell").show_django_cmds()
end, {})

vim.api.nvim_create_user_command("DjangoShellExec", function()
   require("django-shell").exec_django_code()
end, {})

vim.api.nvim_create_user_command("DjangoShellReset", function()
   require("django-shell.utils").reset_project_data()
end, {})

-- vim.api.nvim_create_autocmd("FileType", {
--    pattern = "python",
--    callback = function()
--       vim.api.nvim_create_user_command("DjangoShellExec", function()
--          require("django-shell").exec_django_code()
--       end, {})
--    end,
-- })
