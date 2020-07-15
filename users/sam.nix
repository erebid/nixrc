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
    programs.alacritty.enable = true;
    programs.alacritty.settings = {
      window.padding = {
        x = 10;
        y = 10;
      };
      font = {
        normal = { family = "Iosevka"; };
        size = 11;
      };

      colors = {
        primary = {
          background = "0x282a36";
          foreground = "0xf8f8f2";
        };
        cursor = {
          text = "0x44475a";
          cursor = "0xf8f8f2";
        };
        normal = {
          black = "0x000000";
          red = "0xff5555";
          green = "0x50fa7b";
          yellow = "0xf1fa8c";
          blue = "0xbd93f9";
          magenta = "0xff79c6";
          cyan = "0x8be9fd";
          white = "0xbfbfbf";
        };
        bright = {
          black = "0x4d4d4d";
          red = "0xff6e67";
          green = "0x5af78e";
          yellow = "0xf4f99d";
          blue = "0xcaa9fa";
          magenta = "0xff92d0";
          cyan = "0x9aedfe";
          white = "0xe6e6e6";
        };
      };
    };

    services.gpg-agent = {
      enable = true;
      sshKeys = [ "06330E9E3B7AA150A9B53141325D021A4B20C270" ];
    };
    xdg = let inherit (home-config.home) homeDirectory;
    in rec {
      enable = true;

      configFile."gh/config.yml".text = import ../secrets/gh.nix;

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
    gtk = {
      enable = true;
      theme = {
        package = pkgs.ant-dracula;
        name = "Ant-Dracula";
      };
      iconTheme = {
        package = pkgs.zafiro-icons;
        name = "Zafiro-icons";
      };
    };
    qt = {
      enable = true;
      theme = "gtk2";
    };
  };
}
