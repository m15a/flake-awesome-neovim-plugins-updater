(local {: view} (require :fennel))

(local cjson (require :cjson.safe))

(local {: file->string : string->file} (require :lib.file))


(lambda file->decoded [path]
  (case (file->string path)
    str (cjson.decode str)
    (_ msg) (values nil msg)))

(lambda decoded->file [obj path ?fmt]
  (let [fmt (if (= ?fmt nil) #$1
                (= (type ?fmt) :function) ?fmt
                (error (.. "Invalid formatter: " (view ?fmt))))]
    (case (cjson.encode obj)
      str (string->file (fmt str) path)
      (_ msg) (values nil msg))))

(lambda format/jq [str]
  (let [path (os.tmpname)
        with-cleanup #(do (os.remove path) $...)]
    (case-try (string->file str path)
      true (io.popen (.. "jq -SM . '" path "' 2>/dev/null"))
      file (with-open [f file] (f:read :*a))
      str (with-cleanup str)
      (catch (_ msg) (with-cleanup (values nil msg)))))) 


{:null cjson.null
 : file->decoded
 : decoded->file
 : format/jq}
