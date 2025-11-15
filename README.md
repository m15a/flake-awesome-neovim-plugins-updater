# A script to update Awesome Neovim plugins.

## Description

This script updates `data/plugins/awesome-neovim.json`.
It scrapes Awesome Neovim <https://github.com/rockerBOO/awesome-neovim/>
and collects Neovim plugins registered therein. After that, using
REST APIs of code hosting services, it queries meta data and the
latest commits of the Awesome Neovim plugins. The collected data
are processed out into `data/plugins/awesome-neovim.json`.

## Requirements

- LuaJIT 2.1+
- Lua libraries:
   - http 0.3: <https://github.com/daurnimator/lua-http>
   - cjson 2.1.0: <https://github.com/mpx/lua-cjson>
- Fennel 1.5+

It also depends on the following external programs.

- `nix-prefetch-url`: to compute tarball hash,
- `jq`: to format JSON outputs, and
- `gnused`: to update `README.md`.

## Accessing code hosting services

It supports:

- GitHub
- GitLab
- ~~SourceHut~~: They removed the REST API in favor of GraphQL.
- Codeberg

For using REST API, GitHub personal access token (PAT) is mandatory,
since without the token its rate limit is only 60/hour.
For SourceHut, a PAT is also required. You can generate it by
creating your new account on SourceHut for free. The other services
actually do not require PAT, as the number of GitLab/Codeberg
repositories is sufficiently small.

You should set PATs via the environment variables:

- `GITHUB_TOKEN`
- `GITLAB_TOKEN`
- `SOURCEHUT_TOKEN`
- `CODEBERG_TOKEN`
