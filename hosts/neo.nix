{ config, lib, pkgs, unstablePkgs, ... }:
let
  dzdown =
    pkgs.callPackage
      ({ stdenv, buildGoModule, fetchgit }:
        buildGoModule rec {
          name = "dzdown";

          src = pkgs.fetchFromGitHub {
            owner = "samhza";
            repo = "dzdown";
            rev = "c883286458db79cf2a46a703b7cdc3ad736da35a";
            sha256 = "sha256-+/FQAUcitCP5Uk0DZTK7Q2SdB1mMSL2krbZbD6w9K7A=";
          };

          vendorSha256 = "sha256-K/f/g4KsqAbkadY/s9NBfeGF0u5H2rZiSRJDBDSNLrE=";

          meta = with stdenv.lib; {
            description = "deezer music downloader";
            homepage = "https://github.com/samhza/dzdown";
            license = licenses.isc;
          };
        }
      ) { };
in {
  imports = [
    ../profiles/games
    ../profiles/graphical
    ../profiles/networkmanager
    ../profiles/virt
    ../secrets/location.nix
    ../users/root.nix
    ../users/sam.nix
  ];

  home-manager.users.sam = {
    imports = [ ../profiles/misc/email.nix ../profiles/misc/mpd.nix ];
    programs.alacritty.enable = true;
    services.gpg-agent.enable = true;
    gtk.enable = true;
  };

  users.users.sam.extraGroups = [ "libvirtd" ];

  programs.dconf.enable = true;

  services.redshift.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.wayland = false;

  nixpkgs.config.chromium.enablePepperFlash = true;

  environment.systemPackages = with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-small wrapfig capt-of;
    })
    mercurial
    plan9port
    rclone
    python38Packages.youtube-dl
    (pkgs.ffmpeg-full.override { nv-codec-headers = pkgs.nv-codec-headers; })
    gimp
    (obs-studio.override {
      ffmpeg =
        pkgs.ffmpeg-full.override { nv-codec-headers = pkgs.nv-codec-headers; };
    })
    obs-linuxbrowser
    lutris
  ] ++ [ unstablePkgs.plex-media-player ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  networking.interfaces.enp8s0.useDHCP = true;
  networking.useDHCP = false;

  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "sam";
    group = "users";
    package = unstablePkgs.syncthing;
    configDir = "/home/sam/.config/syncthing";
    dataDir = "/home/sam/.local/share/syncthing";
    declarative = {
      devices = {
        lg.id =
          "S2K26DL-HUAD6FE-55EEZEZ-PH6IBRF-MYJ24KE-6VKUKH4-SITFX3Y-N5TTCQW";
      };
      folders = {
        music = rec {
          devices = [ "lg" ];
          path = "/home/sam/var/music";
          watch = true;
          rescanInterval = 3600;
          type = "sendreceive";
          enable = true;
        };
      };
    };
  };

  systemd = {
    timers.dzdown = {
      wantedBy = [ "timers.target" ];
      partOf = [ "dzdown.service" ];
      timerConfig.OnCalendar = "daily";
    };
    services.dzdown = {
      serviceConfig = {
        Type = "oneshot";
        User = "sam";
        Group = "users";
      };
      after = [ "network-online.target" "fs.target" ];
      script = ''
        cd /home/sam/var/music
        ${dzdown}/bin/dzdown -art-size 800 -arl ${import ../secrets/deezer.arl.nix} $(</home/sam/var/music/list)
      '';
    };
  };

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/sda2";
      preLVM = true;
      allowDiscards = true;
    };
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/18edc2c1-ac07-425a-babf-1c81aae2d2e8";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/932C-4889";
    fsType = "vfat";
  };
  swapDevices =
    [{ device = "/dev/disk/by-uuid/848efac9-2e8b-4006-b051-64d86fc8218b"; }];

  nix.maxJobs = lib.mkDefault 12;
}
