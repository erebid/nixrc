{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ go_1_14 gocode goimports godef ];
}
