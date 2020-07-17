{ pkgs, ... }: {
  imports = [ ./fish ./emacs ./tmux ./go ];

  environment.shellAliases = { v = "$EDITOR"; };

  environment.sessionVariables = {
    PAGER = "less";
    LESS = "-iFJMRWX -z-4 -x4";
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    EDITOR = "emacs";
    VISUAL = "emacs";
  };

  environment.systemPackages = with pkgs; [
    clang
    file
    git-crypt
    gnupg
    less
    ncdu
    tokei
    wget
  ];

  fonts = {
    fonts = [ pkgs.ibm-plex ];
    fontconfig.defaultFonts.monospace =
      [ "IBM Plex Mono Semibold" ];
  };

  documentation.dev.enable = true;

  programs.thefuck.enable = true;
  programs.mtr.enable = true;
}
