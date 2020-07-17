{ lib, config, options, pkgs, ... }:
let
  inherit (builtins) readFile;
  inherit (config.hardware) pulseaudio;
in {
  sound.enable = true;

  services.xserver.windowManager.bspwm = {
    enable = true;
    configFile = ./bspwmrc;
    sxhkd.configFile = ./sxhkdrc;
  };
  environment.systemPackages = with pkgs; [
    (pkgs.alacritty.overrideAttrs (oa: {
      postPatch = oa.postPatch + ''
        sed -i '/with_vsync/d' alacritty/src/window.rs
      '';
    }))
    maim
    rofi
  ];
}
