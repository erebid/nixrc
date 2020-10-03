{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ go gocode goimports godef ];
}
