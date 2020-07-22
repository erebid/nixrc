{ config, lib, pkgs, modulesPath, ... }:

{
	imports =
		[  "${modulesPath}/profiles/qemu-guest.nix"
      ../users/root.nix
      ../users/sam.nix
      ../profiles/develop/fish
		];
	networking.firewall.enable = true;
  services.openssh.enable = true;
  programs.dconf.enable = true;
	security.acme.email = "sam.hernandez.amador@gmail.com";
	security.acme.acceptTerms = true;
	users.users.sam.openssh.authorizedKeys.keys = [
		"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYOBAxJ88ILLN3m+WGUwM0vDWmMIkEFY/J6JVyRR1Brwadd2+BZYF6Alp+XonUY8lGLXafhxjM6dAAsOejbKzrP+NOBM/GeX+uTNfWZ5Y7igSdXC792lGuucaeEuR6ymje6amXPI8GD159o0V6LkBntuHkv2atTzmlSW5dH/WJlHbcfPERIqC6bqKuzcFiM7nVp2p7wsH4J3f3RMEp9FReX8DCPeMoVyXYVQLnMaWGZ1ke9/IUlqyBAMCk+NKiXjE/hQYo9oA4nCT8NNvOSMFQ7GZ/+3M67R3ztCZfYPrqs58Qd2I55+Vq2Ia+ZvO2zwSnWi6FI4GrZvly8zrDRVLZXZMBBPpXxC/hIjyQ+7pUM+6xfYXEnhRy8YsBZgTDsdGzyAyT2PWz4z93TGzxsVhCV0htKd/zbja/Kf8yBoLCgN6q5xox+8L1+aBvDgVihUfPYly+8YlJqO0B03fIgMcO0Oi2T3xf5zW9YVaj/AV35QhegrEoLpachL5YnIX2JiuLV7/xKlS44840Tccc4NmikcHt+Bi/TKYZpqcJXOCUCSezYTu9Bm4HkXGh3j29fu6+xJoA5iWmqurjEfRq2z8kVfa6b22ldo9Mc5mtPxi4hYYHld1P7CSMNHxI+xFSVeM6GMDshOq+dAWX5zON/BNcH74dprkZsjrVyhehygWL4w=="
	];
	time.timeZone = "America/New_York";

	boot.loader.grub.enable = true;
	boot.loader.grub.version = 2;
	boot.loader.grub.device = "/dev/vda";
	boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	# Disks
	fileSystems."/" =
		{ device = "/dev/disk/by-uuid/968f47bc-725e-47a8-9b76-7d26c3b508a8";
			fsType = "ext4";
		};

	swapDevices =
		[ { device = "/dev/disk/by-uuid/20538d48-049f-4995-a74f-ea6fb1d80fcd"; }
		];

	nix.maxJobs = lib.mkDefault 1;

	# Networking
	networking.useDHCP = false;
	networking.interfaces.ens3.useDHCP = true;
	networking.interfaces.ens4.useDHCP = true;
}
