(local fennel (. (require :fennel-nvim) :fennel))

(fn *get-specials [env]
  (fennel.eval "(macro list-specials {}
                  (local specials {})
                  (each [k (pairs _SPECIALS)] (tset specials k true)) specials)
                (list-specials)"
               (unpack (if env [{: env}] []))))
(local specials (*get-specials))

(var *limit* 400)
(fn set-limit [n] "Sets default matches limit to n. Pass math.huge or (/ 1 0) for no limit"
  (assert (-> (type n) (= :number)) "n must be a number.")
  (set *limit* n))

(fn complete [text limit lua-only?]
  "Match supplied text against all globals and (unless disabled) Fennel specials/macros.
  Default limit is 400 but can be changed with set-limit."
  (local limit (or limit *limit*))
  (local matches [])
  (fn add-partials [input tbl prefix]
    (var key (next tbl))
    (while (and key (> limit (# matches)))
      (when (= input (key:sub 1 (# input)))
        (table.insert matches (.. prefix key)))
      (set key (next tbl key)))
    key)
  (fn add-matches [input tbl prefix]
    (local prefix (if prefix (.. prefix :.) ""))
    (if (string.find input "%.")
      (let [(head tail) (input:match "^([^.]+)%.(.*)")
            tbl-head (. tbl head)]
        (when (= :table (type tbl-head))
          (add-matches tail tbl-head (.. prefix head))))
      (add-partials input tbl prefix)))

  (when (not lua-only?) (add-matches text specials))
  (add-matches text (or _G {}))
  matches)

(fn find-start []
  "Used by (n)vim omnifunc. Uses cursor position to find completion starting
  point, returning (values start text-to-match)."
  (local [row col] (vim.api.nvim_win_get_cursor 0))
  (local [line] (vim.api.nvim_buf_get_lines :. (- row 1) row true))
  (var [i found] [col nil])
  (while (and (not found) (> i 0))
    (if (string.find (line:sub i i) "[()%s%#]")
      (set found true)
      (set i (- i 1))))
  (if (>= i 0) (values i (line:sub (+ i 1) col)) i))

(fn omnifunc [fs input lua-only?]
  "Wrapped by viml to set 'omnifunc'. See (n)vim `:help complete-functions`"
  (if (= 1 fs) (find-start)
    (complete (if (not= "" input) input (select 2 (find-start)))
              lua-only?)))

{: omnifunc : complete : find-start : set-limit :get-specials *get-specials}
