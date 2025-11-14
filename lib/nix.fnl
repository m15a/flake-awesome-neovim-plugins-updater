(fn prefetch-url [url]
  (let [cmd (.. "nix-prefetch-url " url " 2>/dev/null"
                " | xargs nix hash convert --hash-algo sha256")]
    (with-open [pipe (io.popen cmd)]
      (let [out (pipe:read :*a)]
        (if (not= "" out)
            (pick-values 1 (out:gsub "\n+" ""))
            (values nil "Failed to run nix-prefetch-url"))))))


{: prefetch-url}
