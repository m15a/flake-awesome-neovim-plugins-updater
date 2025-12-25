(local http (require :lib.http))
(local log (require :lib.log))
(local {: attach-stats} (require :lib.utils))


(lambda fetch []
  (let [base "raw.githubusercontent.com"
        owner "rockerBOO"
        repo "awesome-neovim"
        ref "main"
        path "/README.md"]
    (http.get (.. base "/" owner "/" repo "/" ref path))))

(lambda parse [readme]
  (var state :init)
  (let [plugins []
        active-regex "^%s*%-%s+%[[^/]+/[^/]+%]%("
        plugin-regex ["^%s*%-%s+%[[^%]]+%]%(https?://([^/]+)/([^/]+)/([^/#%)]+)"
                      "^%s*%-%s+%[[^%]]+%]%(https?://([^/]+)/([^/]+)/([^/]+)/([^/#%)]+)"
                      "^%s*%-%s+%[[^%]]+%]%(https?://([^/]+)/([^/#%)]+)"]
        done-regex "^%s*##+%s+Preconfigured%s+[Cc]onfiguration"]
    (each [line (readme:gmatch "[^\n]+") &until (= :done state)]
      (case state
        :init (when (line:match "^%s*##+%s+Plugin%s+[Mm]anager")
                (set state :active))
        :active (if (line:match active-regex)
                    (case (line:match (. plugin-regex 1))
                      (site owner repo)
                      (doto plugins
                        (table.insert {: site : owner : repo}))
                      _ (case (line:match (. plugin-regex 2))
                          ;; GitLab namespace;
                          ;; see https://docs.gitlab.com/ee/user/namespace/
                          (site owner/group subgroup repo)
                          (let [owner (.. owner/group "/" subgroup)]
                            (doto plugins
                              (table.insert {: site : owner : repo}))))
                        _ (case (line:match (. plugin-regex 3))
                            (site repo)
                            (doto plugins
                              (table.insert {: site : repo}))))
                    (line:match done-regex)
                    (set state :done))))
    plugins))

(lambda filter [plugins]
  (collect [key plugin (pairs plugins)]
    (let [{: repo} plugin]
      (when (and (not= "tree-sitter-just" repo)
                 (not= "cheovim" repo)
                 (not= "panvimdoc" repo))
        (values key plugin)))))

(lambda preprocess [plugins]
  "A bit of hand correction are needed:

- Some sourcehut plugins enlist their hub page sr.ht instead of git.sr.ht.
- Authors may enlist their homepage instead of repository URL.
- Some repos are actually not Neovim plugins."
  (let [found {}]
    (collect [_ plugin (ipairs plugins) &into found]
      (let [{: site : owner : repo} (if (= "sr.ht" plugin.site)
                                        (doto plugin
                                          (tset :site "git.sr.ht"))
                                        (= :cj.rs plugin.site)
                                        {:site "github.com"
                                         :owner "cljoly"
                                         :repo "telescope-repo.nvim"}
                                        plugin)
            key (.. site "/" owner "/" repo)]
        (when (and (. found key)
                   (not= key "github.com/nvim-mini/mini.nvim")
                   (not= key "github.com/milanglacier/yarepl.nvim"))
          (log:warn "Duplicate entry: " key))
        (values key {: site : owner : repo})))
    (filter found)))

(lambda plugins []
  (case-try (fetch)
    readme (parse readme)
    plugins (preprocess plugins)
    plugins (attach-stats plugins)
    (catch
      (_ msg)
      (log:error/nil "Failed to get Awesome Neovim plugins: " msg))))


{: plugins}
