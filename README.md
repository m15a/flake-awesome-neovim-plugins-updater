# flake-awesome-neovim-plugins-updater

This is a script to update [flake-awesome-neovim-plugins][1].

## Description

It scrapes [Awesome Neovim][2] and collects the data of Neovim plugins
registered therein. Using the REST APIs of the code hosting services,
e.g. GitHub, it queries each plugin's profile and latest commit
information. The queried data are processed out into
`${DATA_ROOT}/plugins/awesome-neovim.json` to be used in the Nix flake.

## Accessing code hosting services

Supported code hosting services:

- GitHub
- GitLab
- ~~SourceHut~~: They removed the REST API in favor of GraphQL.
- Codeberg

For using the GitHub REST API, your personal access token (PAT) for
GitHub is mandatory. Without the token, its rate limit is only 60/hour.
~~For SourceHut, a PAT of yours is also required. You can generate it by
creating your new account on SourceHut for free.~~ The other services
actually do not require PATs, as the number of GitLab/Codeberg
repositories is sufficiently small.

You can set the PATs via the environment variables:

- `GITHUB_TOKEN`
- `GITLAB_TOKEN`
- `SOURCEHUT_TOKEN`
- `CODEBERG_TOKEN`

## License

[The BSD 3-clause license](LICENSE).

[1]: https://github.com/m15a/flake-awesome-neovim-plugins
[2]: https://github.com/rockerBOO/awesome-neovim
