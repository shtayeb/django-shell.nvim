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

--
-- The project data
--
local config_file = vim.fn.stdpath("data") .. "/django_shell_projects.json"

utils.reset_projects_data = function()
   local file = io.open(config_file, "w")

   if not file then
      return
   end

   file:write("{}")
   file:close()
end

utils.save_project_paths = function(base_dir, python_path, manage_py_path)
   local projects = {}

   -- Load existing projects if the config file exists
   local file = io.open(config_file, "r")

   if file then
      local content = file:read("*a")

      file:close()

      projects = vim.fn.json_decode(content) or {}
   end

   -- Update the project-specific paths
   projects[base_dir] = {
      python_path = python_path,
      manage_py_path = manage_py_path,
   }

   -- Save back to the file
   file = io.open(config_file, "w")

   if file then
      file:write(vim.fn.json_encode(projects))
      file:close()

      print("Paths for project '" .. base_dir .. "' saved successfully.")
   else
      print("Failed to save project paths.")
   end
end

utils.load_project_paths = function(base_dir)
   local file = io.open(config_file, "r")

   if file then
      local content = file:read("*a")

      file:close()

      local ok, projects = pcall(vim.fn.json_decode, content)
      if not ok then
         projects = {}
      end

      if projects and projects[base_dir] then
         return projects[base_dir].python_path, projects[base_dir].manage_py_path
      end
   end

   return nil, nil
end

utils.ask_user_for_project_paths = function(base_dir)
   print("Configuration not found for project: " .. base_dir)

   local python_path = vim.fn.input("Enter the venv python path: ")
   local manage_py_path = vim.fn.input("Enter the path to manage.py file: ")

   if python_path == "" or vim.fn.filereadable(python_path) == 0 then
      -- file is not readable
      print("python is not readable")

      return nil
   end

   -- check if manage_py is readable -> 0|1
   if manage_py_path == "" or vim.fn.filereadable(manage_py_path) == 0 then
      -- file is not readable
      print("manage.py is not readable")

      return nil
   end

   utils.save_project_paths(base_dir, python_path, manage_py_path)

   return python_path, manage_py_path
end

utils.get_project_paths = function()
   local base_dir = utils.cwd

   -- Attempt to load paths for this project
   local python_path, manage_py_path = utils.load_project_paths(base_dir)

   if not python_path then
      python_path = utils.find_python_path()
   end

   if not manage_py_path then
      manage_py_path = utils.find_manage_py()
   end

   -- If paths are not found, ask the user
   if not python_path or not manage_py_path then
      python_path, manage_py_path = utils.ask_user_for_project_paths(base_dir)
   end

   if not python_path or not manage_py_path then
      print("Paths for the project could not be set. Plugin functionality will be limited.")
   end

   return python_path, manage_py_path
end

return utils
