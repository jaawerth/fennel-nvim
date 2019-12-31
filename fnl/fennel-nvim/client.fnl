(require-macros :fennel-nvim.macros)
(local [mpack Session Tcp Socket Child] [(require :mpack)
                                         (require :nvim.session)
                                         (require :nvim.tcp_stream)
                                         (require :nvim.socket_stream)
                                         (require :nvim.child_process_stream)])
(local fmt string.format)

(fn assert-wrap [ok ...]
  (if (not ok) (error (view (v-take 1 ...))) ...))

(fn get-api-doc [mpack-path]
  (let [fh        (io.open (or mpack-path "fnl/fennel-nvim/api.mpack"))
        (ok raw)  (when fh (pcall fh.read fh "*a"))
        (ok docs) (when ok (pcall mpack.unpack raw))]
    (when ok docs)))

(λ mk-api-func [sess fn-info ?api-doc]
  (meta/with (fn [...] (assert-wrap (sess:request fn-info.name ...)))
             (when (not ?api-doc) (set-forcibly! ?api-doc {}))
             (local (arglist doc-lines) (values [] (or ?api-doc.doc [])))
             (table.insert doc-lines
                           (.. "\nnvim api call: " fn-info.name))
             (when (-?> fn-info.parameters (length) (not= 0))
               (local sig [])
               (each [i [type-inf arg] (ipairs fn-info.parameters)]
                 (tset arglist i arg)
                 (tset sig i (.. arg ":" type-inf)))
               (table.insert doc-lines
                             (fmt "Signature: [%s]" (table.concat sig " "))))
             {:fnl/arglist      arglist
              :fnl/docstring    (table.concat doc-lines "\n")
              :nvim/name        fn-info.name
              :nvim/method?     fn-info.method
              :nvim/return-type fn-info.return_type}))

(fn mk-repl-client [conn ?api-doc-mpack-path]
  (let [session          (Session.new conn) 
        (_ [_ api-info]) (assert (session:request "nvim_get_api_info"))
        client           {:session session :_conn conn :api {}}
        api-doc          (get-api-doc ?api-doc-mpack-path)]
    (each [i v (ipairs api-info.functions)]
      (when (not v.deprecated_since)
        (local f (mk-api-func session v (-?> api-doc (. v.name))))
        (tset client.api v.name f)))
    client))

(fn mk-bare-client [_conn ?api-doc-mpack-path]
  (let [session (Session.new _conn)
        wrapper #(fn [...] (assert-wrap (session:request $2 ...)))]
    {: session : _conn :api (setmetatable {} {:__index wrapper })}))
 
(local mk-client (if (meta/when-enabled true) mk-repl-client mk-bare-client))

{:tcp           (λ [host port] (mk-client (Tcp.open host port)))
 :socket        (λ [file] (mk-client (Socket.open file)))
 :child-process (λ [exec ...] (mk-client (Child.spawn [exec ...])))}
