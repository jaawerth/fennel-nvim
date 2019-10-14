command! -nargs=1 -range Fnl call fnl#eval(<f-args>)
command! -nargs=1 -range -complete=file FnlFile call fnl#dofile(<f-args>)
command! -nargs=1 -range=% FnlDo <line1>,<line2>call fnl#do(<f-args>)

if !exists('g:fennel_nvim_init_patch_searchers')
  let g:fennel_nvim_init_patch_searchers = v:true
endif

if !exists('g:fennel_nvim_auto_init')
  let g:fennel_nvim_auto_init = v:true
endif

if g:fennel_nvim_auto_init
  let s:configs = [stdpath('config')] + stdpath('config_dirs')
  for dir in s:configs
    let s:initFnl = dir . "/init.fnl"
    if filereadable(s:initFnl)
      call fnl#dofile(s:initFnl)
    endif
  endfor
endif
