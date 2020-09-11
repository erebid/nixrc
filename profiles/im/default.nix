{ lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    discord
    kotatogram-desktop
  ];
}

