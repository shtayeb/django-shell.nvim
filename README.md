# nvim-django-shell

## Install
If you are using Lazy nvim
```lua
{
	"shtayeb/nvim-django-shell",
	opts = {},
}
```

## Todo:
### Django Shell
Run django code and return the result in a new vertical/horizontal buffer
- [x] Get the code from the current buffer
- [x] Execute the code in django
	- [] handle the windows path errors
- [x] set a django project home var, for access to manage.py
- [x] Put the result in a new buffer
- [] reuse the same buffer for subsequent queries and replace the contents
- [] syntax highlight the result
- [] config var for customisability

### Django Commands
List, show help and examples for django commands in telescope prompt.
- [] Get the commands
- [] Send cmds to  telescope and other telescope configs
- [] Run the command and return the resutl (LOW)

## Plugin Structure
```
├───lua
│   └───django-shell
│         |__  init.lua
└───plugin
      |__  django-shell.lua
```

`lua/`
- Most of the time you don't want the plugin to execute at startup. You want it to run some function when events happened. That is where Lua modules comes into play.

`plugin/`
- The files inside this directory will be executed when Neovim starts.
