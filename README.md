# fennel-nvim [WIP]

**Experimental** plugin allowing native execution of fennel code via neovim's native lua support

I will likely extend this in the future but for now I'm just testing out the idea!

## Usage
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

The usual, either copy to your nvim config dir or use vim-plug ala

```viml
Plug 'jaawerth/fennel-vim'
```
