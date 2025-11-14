(fn get-level []
  (case (os.getenv "LOG_LEVEL")
    (where n (not= nil (tonumber n)))
    (tonumber n)
    (where s (= :string (type s)))
    (if (s:match "^[Dd][Ee][Bb][Uu][Gg]$") 0
        (s:match "^[Ii][Nn][Ff][Oo]$") 1
        (s:match "^[Ww][Aa][Rr][Nn]$") 2
        (s:match "^[Ww][Aa][Rr][Nn][Ii][Nn][Gg]$") 2
        (s:match "^[Ee][Rr][Rr][Oo][Rr]$") 3
        (error (.. "Invalid LOG_LEVEL: " s)))))

(local log (let [mt {:level (or (get-level) 1)}]
                (set mt.__index mt)
                mt))

(fn log.__call [_ ...]
  (io.stderr:write ...)
  (io.stderr:write "\n"))

(fn log.debug [self ...]
  (when (<= self.level 0)
    (self "[DEBUG] " ...)))

(fn log.info [self ...]
  (when (<= self.level 1)
    (self "[INFO] " ...)))

(fn log.warn [self ...]
  (when (<= self.level 2)
    (self "[WARNING] " ...)))

(fn log.error [self ...]
  (when (<= self.level 3)
    (self "[ERROR] " ...)))

(fn log.error/nil [self ...]
  (self:error ...)
  nil)

(fn log.error/exit [self ...]
  (self:error ...)
  (os.exit false))


(setmetatable {} log)
