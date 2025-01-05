# nvim-django-shell

> [!IMPORTANT]
> WIP

## Features
- **Django Commands**

	Easily list, view help, and see examples for Django commands directly in a Telescope prompt.

- **Django Shell**

	Execute Django code and view the results in a new vertical buffer for better readability and debugging.


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
vim.keymap.set("n", "<space>tr", "<cmd>DjangoShellExec<CR>")
vim.keymap.set("n", "<space>tx", "<cmd>DjangoShellReset<CR>")
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

**Django Shell**

Run django code and return the result in a new vertical/horizontal buffer
- [] better python path discovery(different venv setup and etc) 
- [] config var for customisability
	- [] config var to display the sql query as well
	- [] args to switch to shell_plus
- [] create two temporary win and buf only for plugin usage (LOW) 
- [] get highlighted code and run it (LOW)

**Django Commands**

List, show help and examples for django commands in telescope prompt.
- [] Run the command, accept args and return the result (LOW)
