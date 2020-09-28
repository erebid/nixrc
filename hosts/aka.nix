{ config, lib, pkgs, modulesPath, ... }:
let
  esammy =
    pkgs.callPackage
      ({ stdenv, buildGoModule, fetchgit }:
        buildGoModule rec {
          name = "esammy";

          src = pkgs.fetchFromGitHub {
            owner = "samhza";
            repo = "esammy";
            rev = "68b6bdb25f79a43f98b4511132e006a704e6c8e2";
            sha256 = "sha256-0sH3oNCgoq61HF91ubz26J3U8aU8yTxtMPxEjg0ZJAc=";
          };

          vendorSha256 = "sha256-6xcDl98FTbfKuh8xbLKhA+Bc8ndducAGLV+3nPbaTWE=";

          meta = with stdenv.lib; {
            description = "discord meme bot";
            homepage = "https://github.com/samhza/esammy";
            license = licenses.isc;
          };
        }
      ) { };
  certFile = u: "${config.security.acme.certs."${u}".directory}/fullchain.pem";
  keyFile = u: "${config.security.acme.certs."${u}".directory}/key.pem";
  hosts = [ "samhza.com" "irc.samhza.com" "bloat.samhza.com" "3005.me" ];
  signed = map (x: "acme-${x}.service") hosts;
  selfsigned = map (x: "acme-selfsigned-${x}.service") hosts;
in
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ../users/root.nix
    ../users/sam.nix
    ../profiles/develop/fish
  ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 80 6697 ];
  services.openssh.enable = true;
  programs.dconf.enable = true;
  programs.fuse.userAllowOther = true;
  security.acme = {
    email = "sam.hernandez.amador@gmail.com";
    acceptTerms = true;
    preliminarySelfsigned = true;
    certs = {
      "samhza.com" = {
        webroot = "/var/lib/acme/acme-challenge/";
        postRun =  ''
          systemctl restart caddy2.service
        '';
        group = "certs";
        allowKeysForGroup = true;
      };
      "irc.samhza.com" = {
        webroot = "/var/lib/acme/acme-challenge/";
        postRun =  ''
          systemctl restart caddy2.service
          systemctl restart soju.service
        '';
        group = "certs";
        allowKeysForGroup = true;
      };
      "bloat.samhza.com" = {
        webroot = "/var/lib/acme/acme-challenge/";
        postRun =  ''
          systemctl restart caddy2.service
        '';
        group = "certs";
        allowKeysForGroup = true;
      };
      "3005.me" = {
        webroot = "/var/lib/acme/acme-challenge/";
        postRun =  ''
          systemctl restart caddy2.service
        '';
        group = "certs";
        allowKeysForGroup = true;
      };
    };
  };
  users.users.sam.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYOBAxJ88ILLN3m+WGUwM0vDWmMIkEFY/J6JVyRR1Brwadd2+BZYF6Alp+XonUY8lGLXafhxjM6dAAsOejbKzrP+NOBM/GeX+uTNfWZ5Y7igSdXC792lGuucaeEuR6ymje6amXPI8GD159o0V6LkBntuHkv2atTzmlSW5dH/WJlHbcfPERIqC6bqKuzcFiM7nVp2p7wsH4J3f3RMEp9FReX8DCPeMoVyXYVQLnMaWGZ1ke9/IUlqyBAMCk+NKiXjE/hQYo9oA4nCT8NNvOSMFQ7GZ/+3M67R3ztCZfYPrqs58Qd2I55+Vq2Ia+ZvO2zwSnWi6FI4GrZvly8zrDRVLZXZMBBPpXxC/hIjyQ+7pUM+6xfYXEnhRy8YsBZgTDsdGzyAyT2PWz4z93TGzxsVhCV0htKd/zbja/Kf8yBoLCgN6q5xox+8L1+aBvDgVihUfPYly+8YlJqO0B03fIgMcO0Oi2T3xf5zW9YVaj/AV35QhegrEoLpachL5YnIX2JiuLV7/xKlS44840Tccc4NmikcHt+Bi/TKYZpqcJXOCUCSezYTu9Bm4HkXGh3j29fu6+xJoA5iWmqurjEfRq2z8kVfa6b22ldo9Mc5mtPxi4hYYHld1P7CSMNHxI+xFSVeM6GMDshOq+dAWX5zON/BNcH74dprkZsjrVyhehygWL4w=="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpESPS/+RsHiHCRYU4o37tN+ZDYSDfqNQYFp279Nn7e"
  ];

  systemd.services.caddy2 =
    let
      signed = map (x: "acme-${x}.service") hosts;
      selfsigned = map (x: "acme-selfsigned-${x}.service") hosts;
    in
      {
        description = "Caddy web server";
        before = signed;
        wants = signed ++ selfsigned;
        after = [ "network-online.target" "fs.target" ] ++ selfsigned;
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          DynamicUser = true;
          Group = "certs";
          StateDirectory = "caddy";
          ExecStart =
            let
              certFile = name:
                "${config.security.acme.certs.${name}.directory}/fullchain.pem";
              keyFile = name:
                "${config.security.acme.certs.${name}.directory}/key.pem";
              configText = ''
              (acme) {
                handle /.well-known/acme-challenge/* {
                  file_server {
                    root /var/lib/acme/acme-challenge
                  }
                }
              }
              bloat.samhza.com {
                import acme
                encode zstd gzip
                handle /* {
                  reverse_proxy 127.0.0.1:8081
                }
                tls ${certFile "bloat.samhza.com"} ${keyFile "bloat.samhza.com"}
              }
              irc.samhza.com {
                import acme
                encode zstd gzip
                handle /socket {
                  reverse_proxy 127.0.0.1:8080
                }
                handle /* {
                  file_server {
                    root ${builtins.fetchTarball {
                      url = "https://tadeo.ca/u/gamja.tar.gz";
                      sha256 = "0xypjx24vh34yhyyq4nca55qwljc733kwrng26n7780xj5lzcgrk";
                    }}
                  }
                }
                tls ${certFile "irc.samhza.com"} ${keyFile "irc.samhza.com"}
              }
              samhza.com {
                import acme
                encode zstd gzip
                handle /pub/* {
                  uri strip_prefix /pub
                  file_server {
                    root /home/sam/mount/public
                    browse
                  }
                }
                handle /* {
                  file_server {
                    root /srv/samhza.com
                  }
                }
                tls ${certFile "samhza.com"} ${keyFile "samhza.com"}
              }
            '';
              configFile = pkgs.writeText "Caddyfile" configText;
            in
              ''
            ${pkgs.caddy2}/bin/caddy run \
                --config ${configFile} \
                --adapter caddyfile
          '';
          ExecReload = "${pkgs.caddy2}/bin/caddy reload";
          ExecStop = "${pkgs.caddy2}/bin/caddy stop";
          Type = "simple";
          Restart = "on-failure";
          AmbientCapabilities = "cap_net_bind_service";
          CapabilityBoundingSet = "cap_net_bind_service";
          NoNewPrivileges = true;
          LimitNPROC = 8192;
          LimitNOFILE = 1048576;
          Environment = "HOME=%S/private/caddy";
        };
      };
  users.groups.certs = {};
  users.groups.web = {};
  users.users.caddy.extraGroups = [ "certs" "web" ];

  environment.systemPackages = with pkgs; [ fuse ];
  security.wrappers = {
    fusermount = {
      source = "${pkgs.fuse}/bin/fusermount";
      setuid = true;
      setgid = false;
    };
  };
  systemd.services.rclone-mount = {
    description = "Encrypted rclone mount";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target"];
    serviceConfig = {
      ExecStart = ''${pkgs.rclone}/bin/rclone mount schoolcrypt: /home/sam/mount \
        --dir-cache-time 48h \
        --vfs-cache-max-age 48h \
        --vfs-read-chunk-size 10M \
        --vfs-read-chunk-size-limit 512M \
        --allow-other'';
      ExecStop= "${config.security.wrapperDir}/fusermount -uz /home/sam/mount";
      User = "sam";
      Group = "users";
      Environment = [ "PATH=${config.security.wrapperDir}/:$PATH" ];
      Type = "notify";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  systemd.services.bloat = {
    description = "A web client for Mastodon Network";
    after = [ "network-online.target" "fs.target" "acme-bloat.samhza.com.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "bloat";
      ExecStart =
        let
          configText = ''
            listen_address=127.0.0.1:8081
            client_website=https://bloat.samhza.com
            client_name=bloat
            client_scope=read write follow
            database_path=/var/lib/private/bloat/database
            templates_path=${pkgs.bloat.src}/templates
            static_directory=${pkgs.bloat.src}/static
            post_formats=PlainText:text/plain,HTML:text/html,Markdown:text/markdown,BBCode:text/bbcode
            log_file=/var/lib/private/bloat/log
          '';
          configFile = pkgs.writeText "bloat.conf" configText;
        in
          "${pkgs.bloat}/bin/bloat -f ${configFile}";
    };
  };

  systemd.services.esammy = {
    description = "discord meme bot";
    after = [ "network-online.target" "fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "esammy";
      Environment = ["BOT_TOKEN=${import ../secrets/esammy.token.nix}" "PATH=${pkgs.ffmpeg-full}/bin:$PATH"];
      ExecStart = "${esammy}/bin/esammy";
    };
  };

  systemd.services.soju = {
    description = "soju, a user-friendly IRC bouncer";
    after = [ "network-online.target" "fs.target" "acme-irc.samhza.com.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Group = "certs";
      DynamicUser = true;
      StateDirectory = "soju";
      ExecStart =
        let
          configText = ''
            listen ircs://
            listen ws+insecure://:8080
            hostname irc.samhza.com
            tls ${certFile "irc.samhza.com" } ${keyFile "irc.samhza.com"}
            log /var/lib/private/soju/logs
            sql sqlite3 /var/lib/private/soju/soju.db
          '';
          configFile = pkgs.writeText "soju.config" configText;
        in
          "${pkgs.soju}/bin/soju -config ${configFile}";
    };
  };


  time.timeZone = "America/New_York";
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
