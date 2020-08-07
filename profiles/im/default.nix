{ unstablePkgs, ... }: {
  environment.systemPackages = with unstablePkgs; [
    (discord.overrideAttrs (oa: {src = fetchurl {
      url = "https://dl.discordapp.net/apps/linux/0.0.11/discord-0.0.11.tar.gz";
      sha256 = "1saqwigi1gjgy4q8rgnwyni57aaszi0w9vqssgyvfgzff8fpcx54";
    };}))
  ] ++ [ pkgs.kotatogram-desktop ];
}

