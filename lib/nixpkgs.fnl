(import-macros {: assert/type : assert/?type} :lib.prelude)
(local http (require :lib.http))
(local log (require :lib.log))
(local {: attach-stats} (require :lib.utils))


(lambda fetch [?channel]
  (assert/?type :string ?channel)
  (let [base "raw.githubusercontent.com"
        owner "NixOS"
        repo "nixpkgs"
        ref (or ?channel "nixpkgs-unstable")
        path "/pkgs/applications/editors/vim/plugins/vim-plugin-names"]
    (http.get (.. base "/" owner "/" repo "/" ref path))))

(lambda parse [vim-plugin-names]
  "This CSV file has the following columns:

1. repository URL (https://${site}/${owner}/${repo}/),
2. branch name or commit hash (i.e., ref), and
3. alias that will be the nixpkgs attribute name in order to resolve naming
   conflict with the other plugins."
  (icollect [line (vim-plugin-names:gmatch "[^\n]+")]
    (when (line:match "^https://")
      (let [(site owner repo ref alias)
            (line:match "^https://([^/]+)/(.+)/([^/]+)/?,([^,]*),(.*)$")]
        {: site : owner : repo
         :ref (when (and (not= "" ref) (not= :HEAD ref)) ref)
         :alias (when (not= "" alias) alias)}))))

(lambda preprocess [plugins]
  (collect [_ {: site : owner : repo &as plugin} (ipairs plugins)]
    (values (.. site "/" owner "/" repo) plugin))) ; drop duplicates

(lambda plugins []
  (case-try (fetch)
    vim-plugin-names (parse vim-plugin-names)
    plugins (preprocess plugins)
    plugins (attach-stats plugins)
    (catch
      (_ msg)
      (log:error/nil "Failed to get Nixpkgs Vim plugins: " msg))))


{: plugins}
