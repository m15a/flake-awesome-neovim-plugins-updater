(import-macros {: unless} :lib.prelude)
(local hub (require :lib.hub))
(local {: empty?} (require :lib.utils))


(local sourcehut (let [self {:site "git.sr.ht"
                             :token_ {:env "SOURCEHUT_TOKEN"}
                             :base "git.sr.ht/api"}]
                   (setmetatable self {:__index hub})))

(lambda sourcehut.repo/query [_ owner repo]
  (.. owner "/repos/" repo))

(lambda sourcehut.latest/query [_ owner repo]
  (.. owner "/repos/" repo "/log"))

(lambda sourcehut.tarball/url [_ owner repo ref]
  (.. "https://git.sr.ht/" owner "/" repo "/archive/" ref ".tar.gz"))

(fn sourcehut.repo/preprocess [_ {: description : owner : name}]
  {:owner owner.canonical_name
   :repo name
   :description (unless (empty? description) description)
   :homepage (.. "https://git.sr.ht/" owner.canonical_name "/" name)})

(fn sourcehut.latest/preprocess [_ {: results}]
  (let [commit (. results 1)]
    {:rev commit.id
     :timestamp commit.timestamp}))


sourcehut

;; vim: lw+=unless
