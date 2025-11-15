(import-macros {: assert/type} :lib.prelude)
(local {: merge!} (require :lib.prelude))
(local counter (require :lib.counter))
(local json (require :lib.json))


(fn empty? [x]
  (or (= nil x)
      (= "" x)  ; Plugin description might be an empty string.
      (= json.null x))) ; #<userdata NULL>

(lambda timestamp->date [timestamp]
  (assert/type :string timestamp)
  (case (timestamp:match "^%d%d%d%d%-%d%d%-%d%d")
    date date
    _ (values nil (.. "Failed to convert timestamp to date: " timestamp))))

(lambda attach-stats [plugins]
  (let [sites (icollect [_ plugin (pairs plugins)] plugin.site)
        count (counter.new)
        (counts total) (count sites)
        stats (merge! counts {: total})]
    (set stats.time (os.time))
    (values plugins stats)))


{: empty?
 : timestamp->date
 : attach-stats}
