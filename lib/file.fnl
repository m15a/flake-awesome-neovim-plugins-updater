(lambda file->string [path]
  (case (io.open path)
    file (with-open [f file] (f:read :*a))
    (_ msg) (values nil msg)))

(lambda string->file [str path]
  (case (io.open path :w)
    file (with-open [f file] (f:write str))
    (_ msg) (if (msg:match "No such file or directory")
                (case (os.execute (.. "mkdir -p " (path:match "(.*)/")))
                  0 (string->file str path)
                  _ (values nil (.. "Failed to create directory: " path)))
                (values nil msg))))


{: file->string
 : string->file}
