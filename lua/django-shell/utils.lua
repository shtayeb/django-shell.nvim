local utils = {}

utils.default_imports = {
   "from django.db.models import Avg, Case, Count, F, Max, Min, Prefetch, Q, Sum, When",
   "from django.conf import settings",
   "from django.urls import reverse",
   "from django.core.cache import cache",
   "from django.db import transaction",
   "from django.db.models import Exists, OuterRef, Subquery",
}

utils.cwd = vim.fn.getcwd()
utils.iswin = vim.loop.os_uname().sysname == "Windows_NT"

utils.find_python_path = function()
   local default_py_path = "python"
   local common_venv_dirs = { ".venv", "venv", "env" }

   -- Find the virtual environment directory
   local venv_path = ""

   for _, dir in pairs(common_venv_dirs) do
      local dir_path = vim.fn.finddir(dir, utils.cwd .. ";")
      if dir_path ~= "" then
         venv_path = dir_path
         break
      end
   end

   -- Determine the python executable path
   local py_executable = utils.iswin and "python.exe" or "python"

   local py_path = vim.fn.findfile(py_executable, venv_path .. "/**1")

   if py_path == "" then
      return default_py_path
   end

   return py_path
end

utils.find_manage_py = function()
   -- Check if manage.py exists in the current directory
   local manage_py = vim.fn.findfile("manage.py", "**2")

   if manage_py == "" then
      return nil
   end

   -- check if manage_py is readable -> 0|1
   if vim.fn.filereadable(manage_py) == 0 then
      -- file is not readable
      return nil
   end

   return manage_py
end

utils.pprint_queryset = function(shell_output)
   local pprinted_res = {}

   for _, value in pairs(shell_output) do
      local x, y = string.find(value, "<QuerySet ")

      if x and y then
         table.insert(pprinted_res, string.sub(value, 1, y + 2))

         local splited_qset_ob = vim.split(string.sub(value, y + 2), ",")
         for _, qset_obj in pairs(splited_qset_ob) do
            table.insert(pprinted_res, "    " .. vim.trim(qset_obj))
         end
      else
         table.insert(pprinted_res, value)
      end
   end

   return pprinted_res
end

return utils
