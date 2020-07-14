{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (emacsUnstable.override { withGTK2 = false; withGTK3 = false; }) # Emacs 27
    # with Lucid
    gnumake
    gcc
    cmake
    libtool
    libvterm
    nixfmt
  ];
  services.emacs.enable = true;
}
