(local gsub string.gsub)

(fn default-path-transform [p]
  (-> p (gsub "(%/)lua(%/%?.*%.)lua$" "%1fnl%2fnl") (gsub "%.lua$" ".fnl")))

(λ initialize [cfg ?transform]
  "initialize fennel.path synchronizer"
  (when (not ?transform) (set-forcibly! ?transform default-path-transform))
  (var (prev-pkg-path prev-pkg-path-set) (values nil {}))
  (fn update-fennel-paths []
    "Synchronize fennel.path from package.path, using the configured transform"
    (when (not cfg.settings.sync_fennel_path) (lua :return))
    ; prep the transformed contents of package.path in a new container
    (local [new new-pkg-path-set] [[] {}])
    (each [path (string.gmatch (.. package.path ";") "([^;]*);")]
      (local fnl-path (?transform path))
      (tset new-pkg-path-set fnl-path true)
      (tset new (+ (length new) 1) fnl-path))
    ; now insert everything from fennel.path not auto-inserted from package.path
    (each [path (string.gmatch (.. fennel.path ";" "([^;]*);"))]
      (when (not (or (. new-pkg-path-set path) (. prev-pkg-path-set path)))
        (table.insert new path)))
    (set prev-pkg-path package.path)
    (set prev-pkg-path-set new-pkg-path-set)
    (set fennel.path (table.concat new ";"))))
