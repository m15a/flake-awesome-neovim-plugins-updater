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
      version_base = "0.1.0";
      version_prerelease = self.shortRev or self.dirtyShortRev or "unknown";
      version = "${version_base}.${version_prerelease}";
    in
    flakelight-treefmt ./. {
      inputs.self = self;
      systems = import systems;
      package = pkgs: pkgs.callPackage ./package.nix { inherit version; };
      treefmtConfig.programs.nixfmt.enable = true;
    };
}
