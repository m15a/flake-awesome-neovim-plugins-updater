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
        (header stream)
        (case (header:get ":status")
          :200 (values (stream:get_body_as_string) header)
          :404 (values nil (.. "404 NOT FOUND: " uri))
          ;; TODO: Better handling for exceeding rate limit 
          ;; https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api#exceeding-the-rate-limit
          status (if (> n 0)
                     (do
                       (log:warn "Retrying to get: " uri " (status: " status ")")
                       (os.execute (.. "sleep " config.http.retry-interval))
                       (go (- n 1)))
                     (values nil (.. "Failed to get: " uri " (status: " status ")")))) 
        (catch _ (values nil (.. "Unknown failure when getting: " uri)))))
    (go config.http.retry)))


{: get}
