(require-macros :fennel-nvim.macros)

(fn assign [tgt src ...]
  "Merged all supplies pairs tables into tgt table, and returns tgt."
  (when (table? src)
    (each [k v (pairs src)] (tset tgt k v)))
  (if (= (select :# ...) 0) tgt
      (assign tgt ...)))

(fn copy [orig]
  (if (not= :table (type orig)) orig
    (assign {} orig)))

(fn *deep-copy [seen orig]
  (if (not= :table (type orig)) orig
      (if (not= nil (. seen orig)) (. seen orig)
          (let [copy {}]
            (each [o-key o-val (pairs orig)]
              (tset copy (*deep-copy seen o-key ) (*deep-copy seen o-val)))
            (tset seen orig copy)
            copy))))

(fn deep-copy [orig]
  (*deep-copy {} orig))
 

(λ get-in [col path ?nf]
  (var tgt col)
  (local len (length path))
    (for [i 1 len]
      (match tgt
        {(. path i) val} (set tgt val)
        (do (set tgt ?nf) (lua :break))))
    tgt)

(λ get [tgt key ?not-found]
  (match tgt {key v} v _ ?not-found))

(λ assoc-in [tgt path ?value]
  (assert (table? tgt) "Assoc-in requires tgt to be a table.")
  (assert (and (table? path) (< 0 (length path)))
          "Assoc-in expects path to be a table of length > 0")
  (local (result end) (values (assign {} tgt) (length path)))
  (fn recur [parent i]
    (let [done?       (= i end)
          key        (. path i)
          new-child  (if done? ?value
                         (table? (. parent key)) (assign {} (. parent key))
                         {})]
      (tset parent key new-child)
      (if done? result
          (recur new-child (+ i 1)))))
  (pcall recur result 1))

(fn lazy-table [base-table lazy-props loader]
  (local loader (or loader dofile))
  (setmetatable
    base-table
    {:__index (fn [tgt key]
                (local getter (. lazy-props key))
                (if (= nil getter) nil
                  (= (type getter) :function) (tset tgt key (getter tgt key))
                  (tset tgt key (loader getter)))
                (. tgt key))}))

(λ inherit [t index extra-mt-opts]
  (local mt (assign {} extra-mt-opts))
  (tset mt :__index (or index {}))
  (setmetatable t mt))

(fn nil-wrap [f] "wraps function, f, so it always returns nil."
  (fn nil-wrapped [...] (do (f ...) nil)))

{: assign
 : copy
 : get
 : assoc-in
 : lazy-table
 : inherit
 : nil-wrap
 }
