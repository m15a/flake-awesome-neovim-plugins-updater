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
  buildInputs = [ luajit' ];  # for patchShebangs
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r lib $out/
    install -m755 main.fnl $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
        --prefix PATH : ${lib.makeBinPath binDeps} \
        --set FENNEL_PATH "$out/?.fnl;$out/?/init.fnl" \
        --set FENNEL_MACRO_PATH "$out/?.fnl;$out/?/init-macros.fnl"
    runHook postInstall
  '';
}
