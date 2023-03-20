{ pkgs ? import <nixpkgs> {} }:
let
  elixir = pkgs.beam.packages.erlangR25.elixir_1_14;
in
pkgs.mkShell {
  buildInputs = [ elixir ];
}
