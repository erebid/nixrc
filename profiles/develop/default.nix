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
    scc
    wget
  ];

  fonts = {
    fonts = [ pkgs.inconsolata pkgs.noto-fonts ];
    fontconfig.defaultFonts.sansSerif = 
      [ "Noto Sans" ];
    fontconfig.defaultFonts.monospace =
      [ "Inconsolata" ];
  };

  documentation.dev.enable = true;

  programs.mtr.enable = true;
}
