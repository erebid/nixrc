{ lib, config, options, pkgs, ... }:
let
  inherit (config.hardware) pulseaudio;
in {
  sound.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  environment.systemPackages = with pkgs; [
    ant-dracula
    gnome3.gnome-tweaks
    gnomeExtensions.dash-to-panel
    (pkgs.alacritty.overrideAttrs (oa: {
      postPatch = oa.postPatch + ''
        sed -i '/with_vsync/d' alacritty/src/window.rs
      '';
    }))
    rofi
  ];
}
