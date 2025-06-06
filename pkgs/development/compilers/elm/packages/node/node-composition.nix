# This file has been generated by node2nix 1.11.1. Do not edit!

{
  pkgs ? import <nixpkgs> {
    inherit system;
  },
  system ? builtins.currentSystem,
  nodejs ? pkgs."nodejs_20",
}:

let
  nodeEnv = import ../../../../node-packages/node-env.nix {
    inherit (pkgs)
      stdenv
      lib
      runCommand
      writeTextFile
      writeShellScript
      ;
    inherit pkgs nodejs;
    libtool = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.cctools or pkgs.darwin.cctools else null;
  };
in
import ./node-packages.nix {
  inherit (pkgs)
    fetchurl
    nix-gitignore
    stdenv
    lib
    fetchgit
    ;
  inherit nodeEnv;
}
