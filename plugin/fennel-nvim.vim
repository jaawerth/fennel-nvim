command! -nargs=1 Fnl call fnl#eval(<f-args>)
command! -nargs=1 -complete=file FnlFile call fnl#dofile(<f-args>)
