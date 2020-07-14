
{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.services.gpg-agent;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnupg
      pinentry.gtk2
    ];

    home.extraProfileCommands = ''
      export GPG_TTY=$(tty)
      if [[ -n "$SSH_CONNECTION" ]] ;then
        export PINENTRY_USER_DATA="USE_CURSES=1"
      fi
    '';
    programs.gpg.enable = true;
    services.gpg-agent = {
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      maxCacheTtl = 7200;
      enableExtraSocket = true;
      enableSshSupport = true;
      extraConfig = ''
        allow-emacs-pinentry
        allow-preset-passphrase
        no-allow-external-cache
      '';
      verbose = true;
    };
  };
}
