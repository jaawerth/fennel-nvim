(local fennel (. (require :fennel-nvim) :fennel))

(fn *get-specials [env]
  (local args (if env [{: env}] []))
  (fennel.eval
    "(macro list-specials {}
       (local specials {})
       (each [k (pairs _SPECIALS)] (tset specials k true)) specials)
     (list-specials)" (unpack args)))

(local specials (*get-specials))
(fn complete [text limit]
  (local text (if (= "(" (text:sub 1 1)) (text:sub 2) text))
  (local limit (or limit 200))
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
      (let [(head tail) (string.match input "^([^.]+)%.(.*)")
            tbl-head (. tbl head)]
        (when (= :table (type tbl-head))
          (add-matches tail tbl-head (.. prefix head))))
      (add-partials input tbl prefix)))
  (add-matches text specials)
  (add-matches text (or _G {}))
  matches)

(fn find-start []
  (local [row col] (vim.api.nvim_win_get_cursor 0))
  (local [line] (vim.api.nvim_buf_get_lines :. (- row 1) row true))
  (assert (= :string (type line)) "line should be string")
  (var [i found] [col nil])
  (while (and (not found) (> i 0))
    (if (string.find (line:sub i i) "[()%s%#]")
      (set found true)
      (set i (- i 1))))
  (if (>= i 0) (values i (line:sub i col))
    i))

{:omnifunc (fn [fs input]
             (local input (match input "" (select 2 (find-start)) _ input))
             (if (= 1 fs) (find-start) (complete input)))
 :get-specials *get-specials : complete : find-start}
