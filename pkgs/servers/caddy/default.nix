{ stdenv, lib, buildGoModule, plugins ? [],
  modSha256 ? "sha256-CfLPbtTo7ZenUJ2lNLMn06W7Kk4CIWpDJc2/GXNl1Oo=" }:

with lib;

buildGoModule rec {
	pname = "caddy";
	version = "2.0.0";

	goPackagePath = "github.com/caddyserver/caddy/v2";

	subPackages = [ "cmd/caddy" ];

	src = builtins.fetchGit {
		url = "https://github.com/caddyserver/caddy.git";
		rev = "e051e119d1dff75972ed9b07cf97bbb989ba8daa";
	};

	inherit modSha256;
	meta = with stdenv.lib; {
		homepage = https://caddyserver.com;
		description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
		license = licenses.asl20;
		maintainers = with maintainers; [ rushmorem fpletz zimbatm ];
	};
}
