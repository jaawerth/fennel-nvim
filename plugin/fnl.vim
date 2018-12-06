function! FennelEval(code, ...)
  let l:code = substitute(a:code, '"', '\\"', "g")
  let l:toeval = 'require("fennel").eval("' . l:code . '")'
  return a:0 > 1 && luaeval(l:toeval, a:2) || luaeval(l:toeval)
endfunction

function! FennelFile(file)
  let l:file = substitute(a:file, '"', '\\"', "g")
  let l:runfile = 'require("fennel").dofile("' . l:file . '")'
  return luaeval(l:runfile)
endfunction

command! -nargs=1 Fnl call FennelEval(<f-args>)
command! -nargs=1 -complete=file FnlFile call FennelFile(<f-args>) 
