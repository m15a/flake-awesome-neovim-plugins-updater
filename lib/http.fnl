(local http/request (require :http.request))

(import-macros {: assert/type : assert/?type} :lib.prelude)
(local config (require :lib.config))
(local log (require :lib.log))


(lambda get [uri ?header]
  (assert/type :string uri)
  (assert/?type :table ?header)
  (let [uri (if (uri:match "^https?://")
                uri
                (.. "https://" uri))
        request (http/request.new_from_uri uri)]
    (when (not= nil ?header)
      (each [k v (pairs ?header)]
        (request.headers:append k v)))
    (fn go [n]
      (case-try (request:go)
        (header stream) (stream:get_body_as_string)
        (where body (= (header:get ":status") :200)) (values body header)
        (catch _ (if (> n 0)
                     (do
                       (log:warn "Retrying to get: " uri)
                       (os.execute (.. "sleep " config.http.retry-interval))
                       (go (- n 1)))
                     (values nil (.. "Failed to get: " uri)))))) 
    (go config.http.retry)))


{: get}
