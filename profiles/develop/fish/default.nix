{ lib, pkgs, ... }:

{
  users.defaultUserShell = pkgs.fish;

  environment = {
    shellAliases = {
      df = "df -h";
      du = "du -h";
    };

    systemPackages = with pkgs; [
      any-nix-shell
      bzip2
      direnv
      gitAndTools.hub
      gzip
      lrzip
      p7zip
      procs
      fzf
      unrar
      unzip
      xz
    ];
  };

  programs.fish = {
    enable = true;
    promptInit = ''
      any-nix-shell fish --info-right | source
    '';
  };
}
