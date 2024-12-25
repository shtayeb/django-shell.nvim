# nvim-django-shell

## Features
- **Django Commands:** Easily list, view help, and see examples for Django commands directly in a Telescope prompt.
- **Django Shell:** Execute Django code and view the results in a new vertical buffer for better readability and debugging.

> [!IMPORTANT]
> WIP


https://github.com/user-attachments/assets/f50e4c30-04b7-40ad-b532-abc1753e932d



## Install
If you are using Lazy nvim
```lua
{
	"shtayeb/nvim-django-shell",
	opts = {},
	dependencies = { "nvim-telescope/telescope.nvim" }
}
```

## Usage
> [!IMPORTANT]
> **Assumptions:** 
> - Python virtual environment set up in the current working directory and it is named `.venv`.
> - Ensure your `manage.py` file is in the current working directory or one level down.

### Example Directory Structure
```markdown
project_root/
├── **.venv/**
├── app/
│   ├── __init__.py
│   ├── models.py
│   ├── views.py
│   ├── **manage.py**
│   └── ...
└── ...
```

### Keymaps
Create a `.py` file for testing. write the code to be executed in that file and:

```lua
vim.keymap.set("n", "<space>tc", "<cmd>DjangoCommands<CR>")
vim.keymap.set("n", "<space>tc", "<cmd>DjangoShellExec<CR>")
```
**Default Keymaps**
- Run django code in the current buffer
`<leader>tr`

- Show django commands
`<leader>tc`

## Development
clone the repo
```shell
git clone https://github.com/shtayeb/nvim-django-shell.git
```
include the plugin locally using lazy.nvim
```lua
{
	dir = "path/to/nvim-django-shell",
	opts = {},
}
```

run current test file
```shell
:PlenaryBustedFile %
```

## Todo:
- [x] better error handling and notifiers
- [x] create user command for shell and django commands

**Django Shell**
Run django code and return the result in a new vertical/horizontal buffer
- [x] default import for frequently used imports
- [] args to switch to shell_plus
- [] get highlighted code and run it
- [x] add timestamp for each query
- [] config var to display the sql query as well
- [] better python path discovery(different venv setup and etc) 
- [] ability for users to input `python` and `manage.py` path
- [] config var for customisability
- [] create two temporary win and buf only for plugin usage (LOW) 

**Django Commands**
List, show help and examples for django commands in telescope prompt.
- [x] Get the commands
- [x] Send cmds to telescope and other telescope configs
- [x] Send the command to a terminal
- [] Run the command, accept args and return the result (LOW)
