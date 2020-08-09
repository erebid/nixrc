final: prev: {
  ant-dracula = prev.callPackage ./misc/themes/ant-dracula { };
  bloat = prev.callPackage ./servers/bloat { };
  caddy2 = prev.callPackage ./servers/caddy2 { };
  gamemode = prev.callPackage ./os-specific/linux/gamemode { };
  libinih = prev.callPackage ./development/libraries/libinih { };
  soju = prev.callPackage ./applications/networking/soju { };
}
