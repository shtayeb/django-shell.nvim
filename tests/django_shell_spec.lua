local utils = require("django-shell.utils")
local Path = require("plenary.path")

describe("Django Shell Utils", function()
   local test_config_file = Path:new(vim.fn.stdpath("data"), "django_shell_projects_test.json")

   before_each(function()
      -- Override the config_file in the utils module
      utils.config_file = test_config_file.filename

      -- Clean up the test config file before each test
      if test_config_file:exists() then
         test_config_file:rm()
      end
   end)

   after_each(function()
      -- Clean up the test config file after each test
      if test_config_file:exists() then
         test_config_file:rm()
      end
   end)

   it("should save project paths successfully", function()
      -- Arrange: Define project paths
      local base_dir = vim.fn.getcwd()
      local python_path = "/path/to/python"
      local manage_py_path = "/path/to/manage.py"

      -- Act: Call the save_project_paths function
      utils.save_project_paths(base_dir, python_path, manage_py_path)

      -- Assert: Check that the project paths are saved correctly
      local file = io.open(test_config_file.filename, "r")
      local content = file:read("*a")
      file:close()

      local projects = vim.fn.json_decode(content)
      assert.is_not_nil(projects[base_dir]) -- Ensure the project data exists
      assert.equals(projects[base_dir].python_path, python_path)
      assert.equals(projects[base_dir].manage_py_path, manage_py_path)
   end)
end)

