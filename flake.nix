# this file installs a reasonable development environment
# see https://gist.github.com/michaelglass/6d1af2cc869268fa7a17820b72ca7e48
# for simple nix setup instructions
{
  description = "captain dev environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { system = system; config.allowUnfree = true; };
    in
    {
      formatter = pkgs.nixpkgs-fmt;
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          ruby_3_2
          jq
          curl
          # netcat-gnu
          netcat
          ngrok
        ];
      };
    });
}
