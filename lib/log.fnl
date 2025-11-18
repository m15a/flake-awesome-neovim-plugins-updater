(local config (require :lib.config))


(local log (let [mt {:level config.log.level}]
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

(fn log.warn/nil [self ...]
  (self:warn ...)
  nil)

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
