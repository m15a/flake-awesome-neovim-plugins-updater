(import-macros {: unless} (.. (: ... :match "(.+)%.[^.]+") :.prelude))
(local {: empty?} (require (.. (: ... :match "(.+)%.[^.]+") :.utils)))
(local hub (require (.. (: ... :match "(.+)%.[^.]+") :.hub)))


(local github (let [self {:site "github.com"
                          :token_ {:env "GITHUB_TOKEN"}
                          :base "api.github.com"}]
                (setmetatable self {:__index hub})))

(lambda github.repo/query [_ owner repo]
  (.. "/repos/" owner "/" repo))

(lambda github.latest/query [_ owner repo ref]
  (.. "/repos/" owner "/" repo "/commits/" ref))

(lambda github.tarball/url [_ owner repo rev]
  (.. "https://github.com/" owner "/" repo "/archive/" rev ".tar.gz"))

(lambda github.repo/preprocess
  [_ {: default_branch : description : homepage : license : name : owner}]
  {:owner owner.login
   :repo name
   :default_ref default_branch
   :description (unless (empty? description) description)
   :homepage (unless (empty? homepage) homepage)
   :license (unless (empty? license) license.spdx_id)})

(lambda github.latest/preprocess [_ {: sha : commit}]
  {:rev sha
   :timestamp commit.committer.date})


github

;; vim: lw+=unless
