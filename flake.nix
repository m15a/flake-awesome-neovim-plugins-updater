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
      version = "${version_base}+sha.${version_sha}";
      version_base = "0.1.0";
      version_sha = self.shortRev or self.dirtyShortRev or "unknown";
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
        pkgs.callPackage ./package.nix { inherit version luajit; };

      devShell.packages =
        pkgs: with pkgs; [
          luajit.pkgs.readline
          fennel-ls
        ];

      treefmtConfig.programs = {
        nixfmt.enable = true;
        mdformat.enable = true;
        mdformat.plugins =
          ps: with ps; [
            mdformat-gfm
            mdformat-gfm-alerts
          ];
      };
    };
}
