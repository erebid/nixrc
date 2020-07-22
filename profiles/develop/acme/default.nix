{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    plan9port
  ];
}
