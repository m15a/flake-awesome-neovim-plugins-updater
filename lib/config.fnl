(local {: ignore-case-string=} (require :lib.prelude))


(fn data-root []
  (let [default "data"]
    (case (os.getenv "UPDATER_DATA_ROOT")
      (where s (= (type s) :string)) (s:match "(.*[^/])/*$")
      _ default)))

(local data {:root (data-root)})

(fn http-retry []
  (let [default 3]
    (case (os.getenv "UPDATER_HTTP_RETRY")
      (where n (not= nil (tonumber n))) (tonumber n)
      _ default)))

(fn http-retry-interval []
  (let [default 3]
    (case (os.getenv "UPDATER_HTTP_RETRY_INTERVAL")
      (where n (not= nil (tonumber n))) (tonumber n)
      _ default)))

(local http {:retry (http-retry)
             :retry-interval (http-retry-interval)})

(fn log-level []
  (let [default 1]
    (case (os.getenv "UPDATER_LOG_LEVEL")
      (where n (not= nil (tonumber n))) (tonumber n)
      (where s (ignore-case-string= s :debug)) 0
      (where s (ignore-case-string= s :info)) 1
      (where s (ignore-case-string= s :warn)) 2
      (where s (ignore-case-string= s :warning)) 2
      (where s (ignore-case-string= s :error)) 3
      _ default)))

(local log {:level (log-level)})


{: data
 : http
 : log}
