{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    emacsUnstable
    # with Lucid
    mu
    gnumake
    gcc
    cmake
    libtool
    libvterm
    nixfmt
    gnutls
  ];
}
