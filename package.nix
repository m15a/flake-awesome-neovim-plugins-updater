{
  version,
  lib,
  stdenv,
  makeWrapper,
  luajit,
  gnused,
  jq,
}:

let
  binDeps = [
    luajit
    gnused
    jq.bin
  ];
in

stdenv.mkDerivation rec {
  pname = "flake-awesome-neovim-plugins-updater";
  inherit version;
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ luajit ]; # for patchShebangs
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
