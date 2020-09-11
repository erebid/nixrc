{ config, pkgs, ... }:
let inherit (builtins) readFile;
in {
  imports = [ ../develop ./xfce ../networkmanager ../im ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = true;

  environment = {
    systemPackages = with pkgs; [
      emacs
      pulsemixer
      adapta-gtk-theme
      cursor
      dzen2
      feh
      ffmpeg-full
      chromium
      qt5.qtgraphicaleffects
      gnome3.adwaita-icon-theme
      gnome3.networkmanagerapplet
      gnome-themes-extra
      imagemagick
      imlib2
      librsvg
      libsForQt5.qtstyleplugins
      zathura
      xclip
      mpv
    ];
  };

  services.xbanish.enable = true;

  services.gnome3.gnome-keyring.enable = true;

  services.xserver = {
    enable = true;
    xkbVariant = "colemak";
    # displayManager.gdm.enable = true;
    # displayManager.defaultSession = "none+bspwm";
    displayManager.lightdm = {
      enable = true;
    };
  };
}
