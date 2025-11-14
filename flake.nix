{
  inputs = {
    flakelight-treefmt.url = "github:m15a/flakelight-treefmt";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, flakelight-treefmt, systems, ... }:
    flakelight-treefmt ./. {
      inputs.self = self;

      systems = import systems;

      devShell.packages = pkgs: with pkgs; [
        nix-prefetch
        jq.bin
        (luajit.withPackages (
          ps: with ps; [
            http
            cjson
            fennel
            readline
          ]
        ))
      ];

      treefmtConfig.programs.nixfmt.enable = true;
    };
}
