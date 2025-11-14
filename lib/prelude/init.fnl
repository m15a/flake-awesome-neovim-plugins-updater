(local unpack (or table.unpack _G.unpack))

(import-macros {: assert/type} ...)


(fn clone [tbl]
  (collect [k v (pairs tbl)]
    (values k v)))

(fn merge! [tbl* & tbls]
  (each [_ tbl (ipairs tbls)]
    (each [k v (pairs tbl)]
      (set (. tbl* k) v)))
  tbl*)

(fn difference [left right]
  (collect [k v (pairs left)]
    (when (= nil (. right k))
      (values k v))))

(fn ignore-case-string= [s1 s2 ...]
  (assert/type :string s1)
  (assert/type :string s2)
  (and (= (s1:upper) (s2:upper))
       (case [...]
         [s3 & ss] (ignore-case-string= s2 s3 (unpack ss))
         _ true)))


{: clone
 : merge!
 : difference
 : ignore-case-string=}
