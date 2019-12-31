; metadata manipulation macros

; used by metadata macros to tell whether metadata is enabled
(local meta-enabled (pcall _SCOPE.specials.doc
                           (list (sym :doc) (sym :doc)) _SCOPE _CHUNK))
(fn meta/when-enabled [...]
  "Execute body in an implicit `do` when metadata is enabled. Otherwise,
contents are excluded from compiled output. Always returns nil."
  (when meta-enabled `(do ,...)))

(λ meta/with [func ...]
  "Accepts and always returns func. When metadata is enabled, evaluates body 
in an implicit `let` with the global metadata table bound to `$metadata`. If 
body returns a table, it's set as the metadata of func. The $metadata api is:

Get/set entire metadata for a function:
  (. $metadata some-func)                         ; get func's metadata tbl
  (tset $metadata func all-metadata-for-somefunc) ; set func's metadata tbl
  ($metadata:get func key)                        ; get meta field for func
  ($metadata:set func key value)                  ; set meta field for func
  ($metadata:setall func key1 val1 key2 val2 ...) ; set metadata k/v pairs

The built-in metadata keys are :fnl/docstring and :fnl/arglist."
  (if (not meta-enabled) func
    (let [meta-sym (sym :$metadata)]
      `(let [func#     ,func
             ,meta-sym (. (require :fennel) :metadata)]
         (local fn-meta# (do ,...))
         (when (= :table (type fn-meta#))
           (each [k# v# (pairs fn-meta#)]
             (: ,meta-sym :set func# k# v#)))
         func#))))


(fn v-apply [op ...]
  "Applies operation, op, on all supplies values, returning all results as
multiple returns."
  (local exprs [...])
  (for [i 1 (length exprs)] (tset exprs i `(,op ,exprs)))
  `(values ,(unpack exprs)))

(λ v-take [n ...]
  "Limits multivals/varargs from the front to n. `n` must be a number literal >= 0.
Can be used to control function multiple returns like (v-take 1 (func))"
  (assert (and (= :number (type n)) (>= n 0) (= n (math.floor n)))
          "n must be an int >= 0")
  (local bindings `())
  (for [i 1 n] (table.insert bindings (gensym)))
  (if (= n 0) `(values)
      `(let [,bindings ,...] (values ,(unpack bindings)))))

; sugar macros
(fn table? [val] "Same as (= :table (type val))" `(= :table (type ,val)))
(fn first [tbl] "Same as (. tbl 1)" `(. ,tbl 1))
(fn last [tbl] "Same as (. tbl (length tbl))" `(. ,tbl (length ,tbl)))
(λ append [seq val] "Sam as for (tset seq (+ 1 (length seq)) val)"
  `(tset ,seq (+ (length ,seq) 1) ,val))

(fn as-> [value bind-sym ...]
  (local expr-len (select :# ...))
  (when (or (= nil bind-sym) (= expr-len 0))
    (error "as-> expects a non-nil value and bind-sym, and at least one expression"))
  (local let-binds [bind-sym value])
  (for [i 1 (- expr-len 1)]
    (local expr (select i ...))
    (table.insert let-binds bind-sym)
    (table.insert let-binds expr))
  `(let ,let-binds ,(select -1 ...)))


{: meta/when-enabled : meta/with
 : v-apply : v-take 
 : table? : first : last : append
 : as->
 }
