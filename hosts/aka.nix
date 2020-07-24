{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ../users/root.nix
    ../users/sam.nix
    ../profiles/develop/fish
  ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 80 ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 192.241.145.57 -j DROP
    iptables -A OUTPUT -d 192.241.145.57 -j DROP
  '';
  services.openssh.enable = true;
  programs.dconf.enable = true;
  programs.fuse.userAllowOther = true;
  security.acme.email = "sam.hernandez.amador@gmail.com";
  security.acme.acceptTerms = true;
  users.users.sam.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYOBAxJ88ILLN3m+WGUwM0vDWmMIkEFY/J6JVyRR1Brwadd2+BZYF6Alp+XonUY8lGLXafhxjM6dAAsOejbKzrP+NOBM/GeX+uTNfWZ5Y7igSdXC792lGuucaeEuR6ymje6amXPI8GD159o0V6LkBntuHkv2atTzmlSW5dH/WJlHbcfPERIqC6bqKuzcFiM7nVp2p7wsH4J3f3RMEp9FReX8DCPeMoVyXYVQLnMaWGZ1ke9/IUlqyBAMCk+NKiXjE/hQYo9oA4nCT8NNvOSMFQ7GZ/+3M67R3ztCZfYPrqs58Qd2I55+Vq2Ia+ZvO2zwSnWi6FI4GrZvly8zrDRVLZXZMBBPpXxC/hIjyQ+7pUM+6xfYXEnhRy8YsBZgTDsdGzyAyT2PWz4z93TGzxsVhCV0htKd/zbja/Kf8yBoLCgN6q5xox+8L1+aBvDgVihUfPYly+8YlJqO0B03fIgMcO0Oi2T3xf5zW9YVaj/AV35QhegrEoLpachL5YnIX2JiuLV7/xKlS44840Tccc4NmikcHt+Bi/TKYZpqcJXOCUCSezYTu9Bm4HkXGh3j29fu6+xJoA5iWmqurjEfRq2z8kVfa6b22ldo9Mc5mtPxi4hYYHld1P7CSMNHxI+xFSVeM6GMDshOq+dAWX5zON/BNcH74dprkZsjrVyhehygWL4w=="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpESPS/+RsHiHCRYU4o37tN+ZDYSDfqNQYFp279Nn7e"
  ];
  services.caddyv2.enable = true;
  services.caddyv2.modSha256 =
    "sha256-A9ElpmLEW8/NKhp/4VgqB7VstJg+NIZ4Qe+ugN32Xac=";
  services.caddyv2.config = ''
    erebid.dev {
        encode zstd gzip
        log

        handle /* {
          file_server {
              root /var/www/erebid.dev
          }
        }

        handle /pub/* {
        uri strip_prefix /pub
          file_server {
            root /home/sam/public
            browse
          }
        }

        tls /var/certs/erebid.dev.cert.pem /var/certs/erebid.dev.key.pem
    }
  '';
  environment.systemPackages = with pkgs; [ fuse ];
  systemd.services.rclone-mount = {
    description = "Encrypted rclone mount";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target"];
    serviceConfig = {
      ExecStart = ''${pkgs.rclone}/bin/rclone mount schoolcrypt:public /home/sam/public \
        --dir-cache-time 48h \
        --vfs-cache-max-age 48h \
        --vfs-read-chunk-size 10M \
        --vfs-read-chunk-size-limit 512M \
        --allow-other'';
      ExecStop= "${config.security.wrapperDir}/fusermount -uz /home/sam/public";
      User = "sam";
      Group = "users";
      Environment = [ "PATH=${config.security.wrapperDir}/:$PATH" ];
      Type = "notify";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  time.timeZone = "America/New_York";
  security.wrappers = {
    fusermount = {
      source = "${pkgs.fuse}/bin/fusermount";
      setuid = true;
      setgid = false;
    };
  };
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Disks
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/968f47bc-725e-47a8-9b76-7d26c3b508a8";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/20538d48-049f-4995-a74f-ea6fb1d80fcd"; }];

  nix.maxJobs = lib.mkDefault 1;

  # Networking
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
  networking.interfaces.ens4.useDHCP = true;
}
