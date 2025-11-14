{
  version,
  lib,
  stdenv,
  makeWrapper,
  gnused,
  jq,
  luajit,
  nix-prefetch,
}:

let
  luajit' = luajit.withPackages (
    ps: with ps; [
      cjson
      http
      fennel
    ]
  );
  binDeps = [
    gnused
    jq.bin
    luajit'
    nix-prefetch
  ];
in

stdenv.mkDerivation rec {
  pname = "flake-awesome-neovim-plugins-updater";
  inherit version;
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    install -m755 update.fnl $out/bin/${pname}
    wrapProgram $out/bin/${pname} --prefix PATH : ${lib.makeBinPath binDeps}
  '';
}
