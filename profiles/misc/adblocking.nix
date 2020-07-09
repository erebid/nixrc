{ pkgs, ... }:
let
  inherit (builtins) concatStringsSep;
  inherit (pkgs) fetchFromGitHub stdenv gnugrep;
  inherit (builtins) readFile fetchurl;

  hosts = stdenv.mkDerivation {
    name = "hosts";

    src = fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "ddafbadaf6d6fd0f34aa4ae8aa5668fa6601e94c";
      hash = "sha256-7dNPf2NIV+nP30rXN9mKcPFeMzN41d79TpjBxf67Ggg=";
    };

    nativeBuildInputs = [ gnugrep ];

    installPhase = ''
      mkdir -p $out/etc

      # filter whitelist
      grep -Ev '(${whitelist})' hosts > $out/etc/hosts

      # filter blacklist
      cat << EOF >> $out/etc/hosts
      ${blacklist}
      EOF
    '';
  };

  whitelist = concatStringsSep "|" [ ".*pirate(bay|proxy).*" ];

  blacklist = concatStringsSep ''

    0.0.0.0 '' [
      "# auto-generated: must be first"

      # starts here
    ];

in { networking.extraHosts = readFile "${hosts}/etc/hosts"; }
