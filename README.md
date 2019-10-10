# fennel-nvim [WIP]

**Experimental** plugin adding native [fennel](https://fennel-lang.org) support to nvim by utilizing neovim's native lua support. No RPC necessary!

I will likely extend this in the future, but for now I'm just testing out the idea. It should be possible reach seamless integration with a little extra work.

## Usage

The following allows you to run fennel code via lua in neovim.
For the lua API to manipulate neovim from lua/fennel, see `:help lua-vim`, `:help lua`, and `:help api`.

### Evaluate fennel:

Using the `:Fnl` command:

```viml
" via Fnl command
:Fnl (doc doc)
" Output:
" (doc x)
"   Print the docstring and arglist for a function, macro, or special form.
```

**Note:** Unlike `:lua`, will not work with heredoc (`<<`) syntax, as that is only available to built-in
commands. This behavior may become available in the future when neovim implements `:here`
(per [this issue](https://github.com/neovim/neovim/issues/7638)).

Using the `fnl#eval(code[, arg][, compileOpts])` function - like `luaeval()`, you can pass an argument,
which will be bound to the magic global `_A` in the running environment.

```viml
:call fnl#eval('(print (.. "Hello, " _A "!"))', 'World')
" outputs: Hello, World!
```

### Run a file
With `:FnlFile path/to/file.fnl`

For example, if editing some fennel code you want to test in neovim itself,
```viml
:FnlFile %
```

Similarly, you can use `fnl#eval(filepath[, compileOpts])`.

### Via Lua

The [fennel-nvim](lua/fennel-nvim.lua) Lua module offers an API you can use to eval/load/compile Lua.


```lua
local fnl = require('fennel-nvim')

fnl.dofile('path/to/file.fnl')

-- compile some Fennel into Lua for writing
local compiledLua = fnl.compile('path/to/file.fnl')
```

## Install

The usual, either copy to your nvim config dir or use vim-plug or your plugin manager of choice e.g.

```viml
Plug 'jaawerth/fennel-nvim'
```
