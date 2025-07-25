{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  pname = "saucectl";
  version = "0.196.0";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "saucelabs";
    repo = "saucectl";
    tag = "v${version}";
    hash = "sha256-UqGz5pzhICHJ7zRHZYgtf44xUqd15FgtPuG1/6Nc0PQ=";
  };

  ldflags = [
    "-X github.com/saucelabs/saucectl/internal/version.Version=${version}"
    "-X github.com/saucelabs/saucectl/internal/version.GitCommit=${version}"
  ];

  vendorHash = "sha256-zRmTAb4Y86bQHW8oEf3oJqYQv81k1PkvjWnGAy2ZOLM=";

  checkFlags = [ "-skip=^TestNewRequestWithContext$" ];

  meta = {
    description = "Command line interface for the Sauce Labs platform";
    changelog = "https://github.com/saucelabs/saucectl/releases/tag/v${version}";
    homepage = "https://github.com/saucelabs/saucectl";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ luftmensch-luftmensch ];
    mainProgram = "saucectl";
  };
}
