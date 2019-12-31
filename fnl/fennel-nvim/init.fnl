(require-macros :fennel-nvim.macros)
(set package.preload.fennel (or package.preload.fennel
                                #(require :fennel-nvim.lib.fennel)))
(set package.preload.fennelview (or package.preload.fennelview
                                    #(require :fennel-nvim.lib.fennelview)))
(local api vim.api)
(local fennel       (require :fennel))
(local view         (require :fennelview))
(local loaders      (require :fennel-nvim.patch-loaders))
(local compat       (require :fennel-nvim.vim-compat))
(local utils        (require :fennel-nvim.utils))

(local {: assign : assoc-in : nil-wrap} utils)
(local {: buf-set-lines : buf-get-lines} compat.api)
(local fnl {:settings
            {:sync_fennel_paths true
             :auto_init true
             :defaults {:compile  {}
                        :eval     {:env _G :useMetadata true}
                        :dofile   {:env _G :useMetadata true}
                        :searcher {:env _G :useMetadata true}}}})

(fn fnl._update_fennel_paths []
  "Updates fennel.path to keep it in sync with changes to package.path"
  (set fnl._update_fennel_paths
       ((require :fennel-nvim.update-fennel-paths) fnl))
  (fnl._update_fennel_paths))

; core entry functions

(λ fnl.eval [code ?args ?options]
  "Like luaeval, for fennel. Evaluates provided code, interpolating argument
as _A. Unlike luaeval, takes an optional `options` argument for overriding
the default options to fennel.eval."
  (fnl._update_fennel_paths)
  (when (not ?options) (set-forcibly! ?options {}))
  (let [opts (assign {}
                     (or fnl.settings.defaults.eval {})
                     (or ?options {}))
        env (or opts.env {})]
    (set opts.env (assign {} env {:_A ?args}))
    (fennel.eval code opts)))

(λ fnl.dofile [file ?optons]
  "Analog to `luafile` (see `:help luafile`). Accepts a table of Fennel
compiler options as optional second argument."
  (fnl._update_fennel_paths)
  (->> (assign {} fnl.settings.defaults.dofile ?options)
       (fennel.dofile file)))

(λ fnl.dolines [expr s e]
  "Analog to `luado` (see `:help luado`)."
  (fnl._update_fennel_paths)
  (local (nl offset)  (values [] (- 1 s)))
  (local (func lines) (values (fnl.eval (.. "(fn [line linenr] " expr ")"))
                              (buf-get-lines :. (- s 1) e true)))
  (for [i 1 (length lines)]
    (local new-line (func (. lines i) (+ i s -1)))
    (tset nl 1 new-line)
    (when (= :string (type new-line))
      (buf-set-lines :. (+ s i -1) (+ s i) true nl))))


(λ fnl.compile [file ?options]
  (fnl._update_fennel_paths)
  (->> (assign {} (-?> fnl.settings (. :defaults) (. :compile)) ?options)
       (fennel.compile file)))

(λ fnl.patch_loaders [?loader]
  "Inserts ?loader into package.loaders, replacing any previously
inserted using this function. If no loader is provided, creates
one using (fennel.makeSearcher fnl.settings.defaults.searcher)."
  ((. (require :fennel-nvim.patch-loaders) :patch)
      (or ?loader
          (fennel.makeSearcher fnl.settings.defaults.searcher))))

(doto fnl
      (tset :vimdofile (nil-wrap fnl.dofile))
      (tset :vimeval   (nil-wrap fnl.eval))
      (tset :patchSearchers
            #(error "This function has been renamed to patch_loaders")))
