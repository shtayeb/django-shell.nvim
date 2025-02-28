<!-- LOGO -->
<h1>
<p align="center">
  <!-- <img src="https://github.com/user-attachments/assets/fe853809-ba8b-400b-83ab-a9a0da25be8a" alt="Logo" width="128"> -->
  <br>django-shell
</h1>
  <p align="center">
    Seamless integration with Django commands and Shell within Neovim
    <br />
    <a href="#about">About</a>
    ·
    <a href="#development">Developing</a>
  </p>
</p>


## About
Seamless integration with Django commands and shell within Neovim. This plugin leverages the power of Telescope to offer an intuitive interface for executing Django commands and running Django shell code directly from your Neovim editor.

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
	"shtayeb/django-shell.nvim",
	opts = {},
	dependencies = { "nvim-telescope/telescope.nvim" }
}
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
git clone https://github.com/shtayeb/django-shell.nvim.git
```
include the plugin locally using lazy.nvim
```lua
{
	dir = "path/to/django-shell.nvim",
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
- [] config var for customisability
	- [] config var to display the sql query as well
	- [] args to switch to shell_plus
- [] create two temporary win and buf only for plugin usage (LOW) 
- [] get highlighted code and run it (LOW)

**Django Commands**

List, show help and examples for django commands in telescope prompt.
- [] Run the command, accept args and return the result (LOW)
