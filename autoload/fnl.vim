if !exists('g:fennel_nvim_patch_searchers') || g:fennel_nvim_patch_searchers
  lua require('fennel-nvim').patchSearchers()
endif

function! fnl#eval(code, ...)
  let l:args = {
        \ 'args': a:0 > 0 ? a:1 : v:null,
        \ 'code': a:code }
  "let l:compileOpts = a:0 > 1 ? a:1 : {}
  return luaeval('require("fennel-nvim").vimeval(_A.code, _A.args)', l:args)
endfunction

function! fnl#dofile(file, ...)
  let l:compileOpts = a:0 > 1 ? a:1 : v:null
  let l:opts = {'file': a:file, 'opts': l:compileOpts}
  return luaeval('require("fennel-nvim").vimdofile(_A.file, _A.opts)', opts)
endfunction

function! fnl#version()
  return luaeval('require("fennel-nvim").fennel.version')
endfunction

function! fnl#do(expr) range
  call luaeval('require("fennel-nvim").dolines(_A.expr, _A.s, _A.e)',
        \ {'expr': a:expr, 's': a:firstline, 'e': a:lastline})
endfunction

function! fnl#omniComplete(findstart, base)
  return fnl#eval('((. (require :fennel-nvim.complete) :fnl-omnifunc) _A.start _A.input)',
        \ {'start': a:findstart, 'input': a:base})
endfunction

function! fnl#omniCompleteLua(findstart, base)
  return fnl#eval('((. (require :fennel-nvim.complete) :lua-omnifunc) _A.start _A.input)',
        \ {'start': a:findstart, 'input': a:base})
endfunction
