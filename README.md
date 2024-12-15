# nvim-django-shell

## Structure
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

