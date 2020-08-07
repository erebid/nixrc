{ ... }: {
  imports = [ ../misc/adblocking.nix ];

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  networking.nameservers =
    [ "1.1.1.1" "1.0.0.1" ];

  networking.wireless.iwd.enable = true;

  services.resolved = {
    # enable = true;
    # dnssec = "true";
    # fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
    # extraConfig = ''
    #   DNSOverTLS=yes
    # '';
  };

}
