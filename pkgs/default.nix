final: prev: {
  ant-dracula = prev.callPackage ./misc/themes/ant-dracula { };
  caddy = prev.callPackage ./servers/caddy { };
  gamemode = prev.callPackage ./os-specific/linux/gamemode { };
  libinih = prev.callPackage ./development/libraries/libinih { };
  soju = prev.callPackage ./applications/networking/soju { };
}
