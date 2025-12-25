{
  inputs = {
    flakelight-treefmt.url = "github:m15a/flakelight-treefmt";
    systems.url = "github:nix-systems/default";
  };
  outputs =
    {
      self,
      flakelight-treefmt,
      systems,
      ...
    }:
    let
      versionWithSha =
        base:
        let
          sha = self.shortRev or self.dirtyShortRev or "unknown";
        in
        "${base}+sha.${sha}";
    in
    flakelight-treefmt ./. {
      inputs.self = self;
      systems = import systems;
      package =
        pkgs:
        let
          luajit = pkgs.luajit.withPackages (
            ps: with ps; [
              cjson
              http
              fennel
            ]
          );
        in
        pkgs.callPackage ./package.nix {
          version = versionWithSha "0.1.0";
          inherit luajit;
        };
      devShell.packages =
        pkgs: with pkgs; [
          luajit.pkgs.readline
          fennel-ls
        ];
      treefmtConfig.programs = {
        nixfmt.enable = true;
        nixfmt.width = 88;
        mdformat.enable = true;
        mdformat.plugins =
          ps: with ps; [
            mdformat-gfm
            mdformat-gfm-alerts
          ];
      };
    };
}
