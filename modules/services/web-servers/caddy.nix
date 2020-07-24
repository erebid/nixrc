{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.caddyv2;
	configFile = pkgs.writeText "caddyconfig" cfg.config;

in {
	options.services.caddyv2 = {
		enable = mkEnableOption "Caddy web server";

		config = mkOption {
			default = "";
			example = ''
				example.com {
					gzip
					minify
					log syslog

					root /srv/http
				}
			'';
			type = types.lines;
			description = "Configuration file to use with adapter";
		};

		adapter = mkOption {
			default = "caddyfile";
			type = types.str;
			description = "Type of config given";
		};

		dataDir = mkOption {
			default = "/var/lib/caddy";
			type = types.path;
			description = ''
				The data directory, for storing certificates. Before 17.09, this
				would create a .caddy directory. With 17.09 the contents of the
				.caddy directory are in the specified data directory instead.
			'';
		};

		plugins = mkOption {
			default = [];
			type = types.listOf types.str;
			example = [
				"github.com/tarent/loginsrv/caddy"
			];
			description = "List of plugins to use";
		};

		modSha256 = mkOption {
			default = lib.fakeSha256;
			type = types.str;
			description = "Only fill this if custom plugins are added";
		};

		package = mkOption {
			default = (pkgs.caddy.override {
				plugins   = cfg.plugins;
				modSha256 = cfg.modSha256;
			});
			type = types.package;
			description = "Caddy package to use.";
		};
	};

	config = mkIf cfg.enable {
		environment.systemPackages = [ cfg.package ];

		systemd.services.caddy = {
			description = "Caddy web server";
			after    = [ "network-online.target" ];
			wantedBy = [ "multi-user.target"     ];
			serviceConfig = {
				ExecStart = ''
					${cfg.package}/bin/caddy run \
						--config  ${configFile}  \
						--adapter ${cfg.adapter} \
				'';
				ExecReload = "${cfg.package} reload";
				ExecStop   = "${cfg.package} stop";
				Type  = "simple";
				User  = "caddy";
				Group = "caddy";
				Restart = "on-failure";
				StartLimitInterval = 86400;
				StartLimitBurst    = 1;
				AmbientCapabilities   = "cap_net_bind_service";
				CapabilityBoundingSet = "cap_net_bind_service";
				NoNewPrivileges = true;
				LimitNPROC  = 8192;
				LimitNOFILE = 1048576;
				PrivateTmp     = true;
				PrivateDevices = true;
				# ProtectHome    = true;
				ProtectSystem  = "full";
				ReadWriteDirectories = cfg.dataDir;
			};
		};

		users.users.caddy = {
			group = "caddy";
			uid = config.ids.uids.caddy;
			home = cfg.dataDir;
			createHome = true;
		};

		users.groups.caddy.gid = config.ids.uids.caddy;
	};
}
