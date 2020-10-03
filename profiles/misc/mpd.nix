{ config, pkgs, lib, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/var/music";
  };
}
