{ lib, config, options, pkgs, ... }:
let
  inherit (config.hardware) pulseaudio;
in {
  sound.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  environment.systemPackages = with pkgs; [
    ant-dracula
    maim
    slop
    xfce.xfce4-whiskermenu-plugin
    (pkgs.alacritty.overrideAttrs (oa: {
      postPatch = oa.postPatch + ''
        sed -i '/with_vsync/d' alacritty/src/window.rs
      '';
    }))
  ];
}
