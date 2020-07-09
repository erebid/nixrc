{ config, pkgs, lib, ... }:
let
  name = "Samuel Hernandez";
  email = "sam.hernandez.amador@gmail.com";
in {
  users.users.sam = {
    uid = 1000;
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  } // import ../secrets/user.password.nix;

  home-manager.users.sam = let home-config = config.home-manager.users.sam;
  in {
    imports =
      [ ./shells/fish ./services/gnupg ./utilities/git ./utilities/htop ];
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    };

    home.sessionVariables.PASSWORD_STORE_DIR = "$HOME/.secrets/password-store";

    programs.fish.enable = true;
    programs.git = {
      enable = true;
      signing.key = "4AF549A5EA2C4132";
      userEmail = email;
      userName = name;
    };
    programs.htop.enable = true;

    services.gpg-agent = {
      enable = true;
      sshKeys = [ "06330E9E3B7AA150A9B53141325D021A4B20C270" ];
    };
    xdg = let inherit (home-config.home) homeDirectory;
    in rec {
      enable = true;

      cacheHome = "${homeDirectory}/.cache";
      configHome = "${homeDirectory}/.config";
      dataHome = "${homeDirectory}/.local/share";

      userDirs = {
        enable = true;
        desktop = "${dataHome}/desktop";
        documents = "${homeDirectory}/doc";
        download = "${homeDirectory}/tmp";
        music = "${homeDirectory}/var/music";
        pictures = "${homeDirectory}/var/images";
        publicShare = "${homeDirectory}/var/share";
        templates = "${configHome}/templates";
        videos = "${homeDirectory}/var/videos";
      };
    };

  };
}
