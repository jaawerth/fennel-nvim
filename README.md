# fennel-nvim [WIP]

**Experimental** plugin allowing native execution of fennel code via neovim's native lua support

I will likely extend this in the future but for now I'm just testing out the idea!

## Usage

The following allows you to run fennel code via lua in neovim.
For the lua API to manipulate neovim from lua/fennel, see `:help lua-vim`, `:help lua`, and `:help api`.

### Evaluate fennel:

```viml
" via Fnl command
:Fnl (print "ohai!")

" via FennelEval function
:call FennelEval('(print "ohai")')
```

### Run a file
```viml
:FnlFile path/to/file
:call FennelFile("path/to/file")
```

### Via Lua
This plugin also patches `package.searchers`/`package.loaders`, allowing you to require
fennel modules directly from lua.

```viml
:lua require(some-fnl-module).doathing()
```

## Install

The usual, either copy to your nvim config dir or use vim-plug or your plugin manager of choice e.g.

```viml
Plug 'jaawerth/fennel-vim'
```

## Todo
- [ ] Implement a function e.g. `FennelInvoke` for invoking a function from a module
- [ ] Explore other ways to include fennel than directly (maybe wrap luarocks?). May require tinkering with `LUA_PATH` or `package.path`
- [ ] Try and get the `Fnl` command working with heredoc syntax the same way `lua` command does
