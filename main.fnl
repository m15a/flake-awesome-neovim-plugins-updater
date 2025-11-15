#!/usr/bin/env fennel

(local {: view} (require :fennel))
(local {: stablepairs} (require :fennel.utils))

(import-macros {: assert/type} :lib.prelude)
(local json (require :lib.json))
(local log (require :lib.log))
(local hub (require :lib.hub))
(local github (require :lib.github))
(local gitlab (require :lib.gitlab))
(local sourcehut (require :lib.sourcehut))
(local codeberg (require :lib.codeberg))
(local awesome-neovim (require :lib.awesome-neovim))


(local *plugins* {:path (.. (or (os.getenv "DATA_ROOT") "data")
                            "/plugins/awesome-neovim.json")
                  :data {}})

(fn *plugins*.init! [self]
  (set hub.plugins self.data)
  (case (json.file->decoded self.path)
    plugins (each [_ plugin (ipairs plugins)]
              (let [{: site : owner : repo} plugin]
                (when (and site owner repo)
                  (let [key (.. site "/" owner "/" repo)]
                    (tset self.data key plugin)))))))

(lambda update-stats-in-readme [stats marker]
  (assert/type :table stats)
  (assert/type :string marker)
  (case stats.total
    n (let [file "README.md"
            expr (.. "/^\\[" marker "]:/s|-[[:digit:]]+-|-" n "-|")]
        (case (os.execute (.. "sed -Ei " file " -e '" expr "'"))
          0 true
          _ (log:warn/nil "Failed to execute sed")))
    _ (log:warn "Something wrong with stats: " (view stats))))


(*plugins*:init!)
(case-try (awesome-neovim.plugins)
  (an/plugins an/stats) (icollect [_ plugin (stablepairs an/plugins)]
                          (case plugin.site
                            "github.com" (github:plugin plugin)
                            "gitlab.com" (gitlab:plugin plugin)
                            ;; FIXME: sourcehut removed the REST API in favor of GraphQL.
                            ;; https://sourcehut.org/blog/2025-09-01-whats-cooking-q3-2025/
                            ; (where (or "sr.ht" "git.sr.ht")) (sourcehut:plugin plugin)
                            "codeberg.org" (codeberg:plugin plugin)
                            _ {}))
  plugins (do
            (log:info "Awesome Neovim plugins:\n" (view an/stats))
            (update-stats-in-readme an/stats :b3)
            (case (json.decoded->file plugins *plugins*.path json.format/jq)
              true (os.exit true)
              (_ msg) (log:error/exit msg)))
  (catch _ (os.exit false)))
