{
  inputs.flakelight-treefmt.url = "github:m15a/flakelight-treefmt";

  outputs = { self, flakelight-treefmt, ... }:
    flakelight-treefmt ./. {
      inputs.self = self;

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      treefmtConfig.programs.nixfmt.enable = true;
    };
}
