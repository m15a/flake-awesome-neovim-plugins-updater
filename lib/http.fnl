(local http/request (require :http.request))

(import-macros {: assert/type : assert/?type} :lib.prelude)
(local log (require :lib.log))


(lambda get [uri ?header ?retry ?interval]
  (assert/type :string uri)
  (assert/?type :table ?header)
  (assert/?type :number ?retry)
  (assert/?type :number ?interval)
  (let [uri (if (uri:match "^https?://")
                uri
                (.. "https://" uri))
        request (http/request.new_from_uri uri)
        retry (or ?retry 3)
        interval (or ?interval 3)]
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
                       (os.execute (.. "sleep " interval))
                       (go (- n 1)))
                     (values nil (.. "Failed to get: " uri)))))) 
    (go retry)))


{: get}
