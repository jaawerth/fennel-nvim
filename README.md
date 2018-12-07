# fennel-nvim [WIP]

**Experimental** plugin adding native [fennel](https://fennel-lang.org) support to nvim by utilizing neovim's native lua support. No RPC necessary!

I will likely extend this in the future, but for now I'm just testing out the idea. It should be possible reach seamless integration with a little extra work.

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
- [ ] Support a `fnl/` equivalent to the `lua/` dirs in runtime path, allowing autorunning of `fnl/init.fnl`
- [ ] Implement a function e.g. `FennelInvoke` for invoking a function from a module
- [ ] Explore other ways to include fennel than directly (maybe wrap luarocks?).
- [ ] Allow users to supply their own fennel version.
- [ ] Allow `Fnl` to support heredoc syntax for parity with nvim's `lua` command.
