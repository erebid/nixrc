{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (emacsUnstable.override { withGTK2 = false; withGTK3 = false; }) # Emacs 27 with Lucid
    nixfmt
  ];
  services.emacs.enable = true;
}
