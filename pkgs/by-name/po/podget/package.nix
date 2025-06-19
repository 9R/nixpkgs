{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  writeShellApplication,
  coreutils,
  findutils,
  gawk,
  iconv,
  wget,
}:

let
  podget = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "podget";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "dvehrs";
      repo = "podget";
      tag = "V${finalAttrs.version}";
      hash = "sha256-0I42UPWTdSzfRJodB1v3BNI5vwt8GRGpHR7eACoR9YQ=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -m755 -D podget $out/bin/podget

      runHook postInstall
    '';
  });
in
writeShellApplication {
  name = "podget";
  runtimeInputs = [
    podget
    coreutils
    findutils
    gawk
    iconv
    wget
  ];
  text = ''
    podget "$@"
  '';

  meta = with lib; {
    description = "Podcast aggregator optimized for running as a scheduled job (i.e. cron) on Linux";
    homepage = "https://github.com/dvehrs/podget";
    changelog = "https://github.com/dvehrs/podget/blob/dev/Changelog";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ _9R ];
    mainProgram = "podget";
  };
}
