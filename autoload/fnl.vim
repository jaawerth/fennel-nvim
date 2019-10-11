function! fnl#eval(code, ...)
  let l:args = {
        \ 'args': a:0 > 0 ? a:1 : v:null,
        \ 'code': a:code }
  "let l:compileOpts = a:0 > 1 ? a:1 : {}
  return luaeval('require("fennel-nvim").vimeval(_A.code, _A.args)', l:args)
endfunction

function! fnl#dofile(file, ...)
  let l:compileOpts = a:0 > 1 ? a:1 : {}
  let l:opts = {'file': a:file, 'opts': l:compileOpts}
  return luaeval('require("fennel-nvim").vimdofile(_A.file, _A.opts)', opts)
endfunction

function! fnl#version()
  return luaeval('require("fennel-nvim").version')
endfunction
