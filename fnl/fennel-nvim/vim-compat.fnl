(require-macros :fennel-nvim.macros)
(local vim _G.vim)
(local nvim_call (and vim vim.api vim.api.nvim_call_function))
(local is-nvim (let [(ok res)  (pcall nvim_call :has [:nvim])]
                 (and ok (= res 1))))

(local (api shim-targets) (values {} [:buf_set_lines :buf_get_lines]))
(if is-nvim
    ; just copy from vim.api
    (each [_ k (ipairs shim-targets)]
      (tset api (k:gsub "_" "-") (. vim.api (.. :nvim_ k))))

    ; vim shims
    (do
      (λ api.buf-get-lines [bufnr start end strict?]
        (let [buf   (vim.buffer bufnr)
              b-len (length buf)
              ; convert 0-based indices to 1-based, accounting for negatives
              s     (+ 1 (if (< 0 start) (+ start b-len 1) start))
              e     (+ 1 (if (< 0 end)   (+ end b-len 1)   end))
              lines []]
          (if strict?
              (assert (and (<= 0 s) (>= b-len s) (<= 0 e) (>= b-len e))
                      "Index out of bounds")
              ; clamp to within 1 and b-len + 1
              (set-forcibly! (s e)
                             (values (math.min (+ 1 b-len) (math.max 1 s))
                                     (math.min (+ 1 b-len) (math.max 1 e)))))
          (for [i (- s 1) e] (append lines (. buf (+ i 1))))
          lines))

      (λ api.buf-set-lines [bufnr start end strict? replacement]
        (let [buf   (vim.buffer bufnr)
              r-len (length replacement)
              b-len (length buf)
              ; convert 0-based indices to 1-based, accounting for negatives
              s     (+ 1 (if (< 0 start) (+ start b-len 1) start))
              e     (+ 1 (if (< 0 end)   (+ end b-len 1)   end))
              lines []]
          (if strict?
              (assert (and (<= 0 s) (>= b-len s) (<= 0 e) (>= b-len e))
                      "Index out of bounds")
              ; clamp to within 1 and b-len + 1
              (set-forcibly! (s e)
                             (values (math.min (+ 1 b-len) (math.max 1 s))
                                     (math.min (+ 1 b-len) (math.max 1 e)))))
          ; remove extra lines in buffer if replacemnt lines are shorter than range
          (for [i 1 (- (- e s) r-len)]
            (tset buf s nil))
          (for [i 0 (- r-len 1)]
            (tset buf (+ i s) (. replacement (+ i 1))))))))

; return module
{: api : is-nvim}

