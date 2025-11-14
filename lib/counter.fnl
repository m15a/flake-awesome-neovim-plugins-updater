(import-macros {: assert/type} (.. (: ... :match "(.+)%.[^.]+") :.prelude))
(local {: clone} (require (.. (: ... :match "(.+)%.[^.]+") :.prelude)))


(local counter (let [self {:counts {} :total 0}]
                 (set self.__index self)
                 self))

(fn counter.new []
  (setmetatable {} counter))

(lambda counter.count [self tbl]
  (assert/type :table tbl)
  (let [counts (accumulate [acc (clone self.counts) _ x (ipairs tbl)]
                 (doto acc
                   (tset x (case (. acc x)
                             n (+ n 1)
                             _ 1))))
        total (accumulate [n 0 _ c (pairs counts)]
                (+ n c))]
    (set self.counts counts)
    (set self.total total)
    (values self.counts self.total))) 

(set counter.__call counter.count) 


counter
