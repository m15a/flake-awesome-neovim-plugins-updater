(local unpack (or table.unpack _G.unpack))
(local {: view} (require :fennel))

(local cjson (require :cjson))

(import-macros {: assert/type : assert/?type : unless}
               (.. (: ... :match "(.+)%.[^.]+") :.prelude))
(local {: clone : merge! : ignore-case-string=}
       (require (.. (: ... :match "(.+)%.[^.]+") :.prelude)))
(local {: timestamp->date}
       (require (.. (: ... :match "(.+)%.[^.]+") :.utils)))
(local http (require (.. (: ... :match "(.+)%.[^.]+") :.http)))
(local json (require (.. (: ... :match "(.+)%.[^.]+") :.json)))
(local nix (require (.. (: ... :match "(.+)%.[^.]+") :.nix)))
(local log (require (.. (: ... :match "(.+)%.[^.]+") :.log)))


(local hub {:site "missing.hub"
            :token_ {:env "MISSING_TOKEN"}
            :base "api.missing-hub.com"
            :cache-dir "data/.cache"
            :plugins {}})

(fn hub.token [self]
  (if self.token_.missing?
      nil
      (or self.token_.cache
          (case (os.getenv self.token_.env)
            token (do
                    (set self.token_.cache token)
                    token)
            _ (do
                (log:warn "Missing " self.token_.env)
                (set self.token_.missing? true)
                nil)))))

(lambda hub.query [self path]
  (assert/type :string path)
  (let [token (self:token)
        header {:content-type "application/json"
                :authorization (when token (.. "token " token))}
        base (: self.base :match "(.*[^/])/*$")
        path (: path :match "^/*([^/].*)")]
    (case (http.get (.. base "/" path) header) 
      (body header*) (values (cjson.decode body) header*)
      (_ msg) (values nil msg))))

(lambda hub.repo/cache [self owner repo]
  (assert/type :string owner)
  (assert/type :string repo)
  (.. (: self.cache-dir :match "(.*[^/])/*$")
      "/site=" self.site
      "/owner=" owner
      "/repo=" repo
      "/info.json"))

(lambda hub.latest/cache [self owner repo ?ref]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/?type :string ?ref)
  (.. self.cache-dir
      "/site=" self.site
      "/owner=" owner
      "/repo=" repo
      "/refs/" (if ?ref (.. ?ref ".json") "default.json")))

(fn hub.repo/query []
  (error "Override hub.repo/query!"))

(fn hub.latest/query []
  (error "Override hub.latest/query!"))

(fn hub.repo/preprocess []
  (error "Override hub.repo/preprocess!"))

(fn hub.latest/preprocess []
  (error "Override hub.latest/preprocess!"))

(lambda repo/validate [repo]
  (assert/type :table repo)
  (and (= :string (type repo.site))
       (= :string (type repo.owner))
       (= :string (type repo.repo))
       (or (= repo.description nil)
           (= :string (type repo.description)))
       (or (= repo.homepage nil)
           (= :string (type repo.homepage)))
       (or (= repo.license nil)
           (= :string (type repo.license)))))

(lambda latest/validate [commit]
  (assert/type :table commit)
  (and (= :string (type commit.rev))
       (= :string (type commit.timestamp))))

(macro with-cache [{: expire : path} & body]
  (let [alive? (if (= expire nil)
                   `(fn [] true)
                   `(fn [time#] (< (os.time) (+ time# ,expire))))]
    `(let [json# (require :lib.json)
           cache# (json#.file->decoded ,path)]
       (if (and cache# (,alive? cache#.time))
           cache#
           (let [out# (do ,(unpack body))]
             (case (json#.decoded->file out# ,path)
               true out#
               (_# msg#) (error msg#)))))))

(fn hub.repo [self {: owner : repo}]
  (assert/type :string owner)
  (assert/type :string repo)
  (log:debug "Get " self.site " repo: " owner "/" repo)
  (with-cache {:path (self:repo/cache owner repo) :expire (* 8 60 60)}
    (log:debug "Cache " self.site " repo: " owner "/" repo)
    (case (self:query (self:repo/query owner repo))
      data (let [repo_ (doto (self:repo/preprocess data)
                         (tset :site self.site))]
             (if (repo/validate repo_)
                 (do
                   (unless (ignore-case-string= owner repo_.owner)
                     (log:warn "Owner changed: "
                               self.site
                               "/{" owner " -> " repo_.owner
                               "}/" repo))
                   (unless (ignore-case-string= repo repo_.repo)
                     (log:warn "Repo changed: "
                               self.site
                               "/" owner
                               "/{" repo " -> " repo_.repo "}"))
                   (doto repo_
                     (tset :time (os.time))))
                 (log:error/nil (.. "Invalid repo: " (view repo_)))))
      (_ msg) (log:error/nil msg))))

(fn hub.tarball/url []
  (error "Override hub.tarball/url!"))

(lambda hub.tarball [self {: owner : repo : rev}]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/type :string rev)
  (log:info "Update: " self.site "/" owner "/" repo)
  (let [url (self:tarball/url owner repo rev)]
    (case (nix.prefetch-url url)
      sha256 {: url : sha256}
      (_ msg) (log:error/nil (.. "Failed to get tarball: " msg)))))

(lambda hub.latest/known [self {: owner : repo}]
  (assert/type :string owner)
  (assert/type :string repo)
  (let [key (.. self.site "/" owner "/" repo)
        {: date : rev : url : sha256} (or (. self.plugins key) {})]
    {: date : rev : url : sha256}))

(lambda hub.latest [self {: owner : repo : ref}]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/type :string ref)
  (log:debug "Get " self.site " latest commit: " owner "/" repo "/" ref)
  (with-cache {:path (self:latest/cache owner repo ref) :expire (* 8 60 60)}
    (log:debug "Cache " self.site " latest commit: " owner "/" repo "/" ref)
    (let [known (self:latest/known {: owner : repo})]
      (case (self:query (self:latest/query owner repo ref))
        data (let [latest (self:latest/preprocess data)]
               (if (latest/validate latest)
                   (if (= known.rev latest.rev)
                       (doto known
                         (tset :time (os.time)))
                       (case (self:tarball {: owner : repo :rev latest.rev})
                         {: url : sha256} (doto latest
                                            (tset :time (os.time))
                                            (tset :url url)
                                            (tset :sha256 sha256))
                         _ known))
                   (log:error/nil (.. "Invalid latest commit: " (view latest)))))
        (_ msg) (log:error/nil msg)))))

(lambda hub.plugin [self {: owner : repo : ?ref}]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/?type :string ?ref)
  (let [known (doto (clone (let [key (.. self.site "/" owner "/" repo)]
                             (or (. self.plugins key) {})))
                ;; Could be removed in the latest data.
                (tset :description nil)
                (tset :homepage nil)
                (tset :license nil))]
    (case-try (self:repo {: owner : repo})
      repo_ (self:latest {: owner : repo :ref (or ?ref repo_.default_ref)})
      latest (doto (merge! known repo_ latest)
               (tset :default_ref nil)
               (tset :time nil)
               (tset :timestamp nil)
               (tset :date (if latest.timestamp
                               (timestamp->date latest.timestamp)
                               latest.date)))
      (catch _ nil))))


hub

;; vim: lw+=unless,with-cache
