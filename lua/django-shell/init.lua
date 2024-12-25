local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local config = require("telescope.config").values
local previewers = require("telescope.previewers")
local tels_prevs_utils = require("telescope.previewers.utils")
local utils = require("django-shell.utils")

local log = require("plenary.log"):new()
log.level = "debug"

local M = {}

M.result_winnr = -1
M.result_bufnr = -1
M.python_path = utils.find_python_path()
M.manage_py_path = utils.find_manage_py()

function M.setup(opts)
   opts = opts or {}

   vim.keymap.set("n", "<space>tc", function()
      M.show_django_cmds()
   end)

   vim.keymap.set("n", "<space>tr", function()
      M.exec_django_code()
   end)
end

M.exec_django_code = function()
   if not M.python_path or not M.manage_py_path then
      vim.notify("Not a django project or project setup is incompatible. Please read the readme.", "error")
      return
   end

   -- the all text in the current buffer till the cursor position
   local curr_buf = vim.api.nvim_get_current_buf()
   local cursor_position = vim.api.nvim_win_get_cursor(0) -- 0 -> current window

   local code = vim.api.nvim_buf_get_lines(curr_buf, 0, cursor_position[1], false)

   if not vim.api.nvim_buf_is_valid(M.result_bufnr) then
      M.result_bufnr = vim.api.nvim_create_buf(false, true)
   end

   if not vim.api.nvim_win_is_valid(M.result_winnr) then
      -- create a new window
      -- split: Split direction: "left", "right", "above", "below".
      M.result_winnr = vim.api.nvim_open_win(M.result_bufnr, false, { split = "right", win = 0 })
   end

   -- the replacement handles empty lines
   local default_imports_str = table.concat(utils.default_imports, ";")
   local code_str = table.concat(code, ";"):gsub(";;+", ";")

   local final_code = default_imports_str .. ";" .. code_str

   local cmd = { M.python_path, M.manage_py_path, "shell", "--command", final_code }

   vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
         if data then
            local pp_output = utils.pprint_queryset(data)

            -- get a timestamp in the format HH:MM:SS AM/PM
            local timestamp = "######### " .. os.date("%I:%M:%S %p") .. " #########"
            table.insert(pp_output, 1, timestamp)

            vim.api.nvim_buf_set_lines(M.result_bufnr, -1, -1, false, pp_output)
         end
      end,
      on_stderr = function(_, data)
         if data then
            vim.api.nvim_buf_set_lines(M.result_bufnr, -1, -1, false, data)
         end
      end,
   })

   -- syntax highlight the result buffer texts
   tels_prevs_utils.highlighter(M.result_bufnr, "python")
end

M.show_django_cmds = function(opts)
   if not M.python_path or not M.manage_py_path then
      vim.notify("Not a django project or project setup is incompatible. Please read the readme.", "error")
      return
   end

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
         attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
               local selection = action_state.get_selected_entry()
               local selected_command = string.format("%s %s %s", M.python_path, M.manage_py_path, selection.value)
               actions.close(prompt_bufnr)

               -- open a new terminal and put the command there
               vim.cmd.vnew()
               vim.cmd.term()
               vim.cmd.wincmd("J")
               vim.api.nvim_win_set_height(0, 10)

               local job_id = vim.bo.channel
               vim.fn.chansend(job_id, { selected_command })
            end)
            return true
         end,
      })
      :find()
end

-- M.python_path = "/home/stayeb/Code/immap/rh/.venv/bin/python"
-- M.manage_py_path = "/home/stayeb/Code/immap/rh/src/manage.py"
--
-- M.show_django_cmds()
--
return M
