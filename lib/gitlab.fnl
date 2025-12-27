(import-macros {: unless} :lib.prelude)
(local hub (require :lib.hub))
(local {: empty?} (require :lib.utils))


(local gitlab (let [self {:site "gitlab.com"
                          :token_ {:env "GITLAB_TOKEN"}
                          :base "gitlab.com/api/v4"}]
                (setmetatable self {:__index hub})))

(lambda gitlab.repo/query [_ owner repo]
  (.. "projects/" owner "%2F" repo))

(lambda gitlab.latest/query [_ owner repo ref]
  (.. "projects/" owner "%2F" repo "/repository/branches/" ref))

(lambda gitlab.tarball/url [_ owner repo ref]
  (.. "https://gitlab.com/" owner "/" repo "/-/archive/" ref ".tar.gz"))

(lambda gitlab.repo/preprocess
  [_ {: default_branch : description : web_url : path : namespace
      : created_at : updated_at : last_activity_at : archived
      : star_count}]
  {:owner namespace.path
   :repo path
   :default_ref default_branch
   :description (unless (empty? description) description)
   :homepage (unless (empty? web_url) web_url)
   : created_at
   ;; See https://docs.gitlab.com/api/projects/
   :updated_at (or updated_at last_activity_at)
   :archived (when archived archived)
   :stars_count star_count})

(lambda gitlab.latest/preprocess [_ {: commit}]
  {:rev commit.id
   :timestamp commit.committed_date})


gitlab

;; vim: lw+=unless
