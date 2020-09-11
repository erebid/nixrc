{ config, lib, pkgs, unstablePkgs, ... }: 
{
  imports = [
    ../profiles/games
    ../profiles/graphical
    ../profiles/networkmanager
    ../profiles/virt
    ../secrets/location.nix
    ../users/root.nix
    ../users/sam.nix
  ];

  users.users.sam.extraGroups = [ "libvirtd" ];

  programs.dconf.enable = true;

  services.redshift.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.wayland = false;

  nixpkgs.config.chromium.enablePepperFlash = true;

  environment.systemPackages = with pkgs; [ 
mercurial
plan9port
rclone
python38Packages.youtube-dl
 (pkgs.ffmpeg-full.override { nv-codec-headers = pkgs.nv-codec-headers;})
gimp (obs-studio.override { ffmpeg = pkgs.ffmpeg-full.override { nv-codec-headers = pkgs.nv-codec-headers;}; }) obs-linuxbrowser lutris ];

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
