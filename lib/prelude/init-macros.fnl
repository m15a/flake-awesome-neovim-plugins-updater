(local unpack (or table.unpack _G.unpack))

(fn assert/type [expected x]
  `(when (not= ,expected (type ,x))
     (let [got# ((. (require :fennel) :view) ,x)]
       (error (.. ,expected " expected, got " got#)))))

(fn assert/?type [type? x]
  `(when (not= nil ,x)
     (assert/type ,type? ,x)))

(fn unless [condition & body]
  `(when (not ,condition)
     ,(unpack body)))


{: assert/type
 : assert/?type
 : unless}
