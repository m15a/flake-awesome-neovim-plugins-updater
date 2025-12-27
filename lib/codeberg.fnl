(import-macros {: unless} :lib.prelude)
(local hub (require :lib.hub))
(local {: empty?} (require :lib.utils))


(local codeberg (let [self {:site "codeberg.org"
                            :token_ {:env "CODEBERG_TOKEN"}
                            :base "codeberg.org/api/v1"}]
                  (setmetatable self {:__index hub})))

(lambda codeberg.repo/query [_ owner repo]
  (.. "repos/" owner "/" repo))

(lambda codeberg.latest/query [_ owner repo ref]
  (.. "repos/" owner "/" repo "/branches/" ref))

(lambda codeberg.tarball/url [_ owner repo rev]
  (.. "https://codeberg.org/" owner "/" repo "/archive/" rev ".tar.gz"))

(lambda codeberg.repo/preprocess
  [_ {: default_branch : description : html_url : website : name : owner
      : stars_count}]
  {:owner owner.username
   :repo name
   :default_ref default_branch
   :description (unless (empty? description) description)
   :homepage (or (unless (empty? website) website)
                 (unless (empty? html_url) html_url))
   : stars_count})

(lambda codeberg.latest/preprocess [_ {: commit}]
  {:rev commit.id :timestamp commit.timestamp})


codeberg

;; vim: lw+=unless
