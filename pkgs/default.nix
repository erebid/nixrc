final: prev: {
  gamemode = prev.callPackage ./os-specific/linux/gamemode { };
  libinih = prev.callPackage ./development/libraries/libinih { };
  ant-dracula = prev.callPackage ./misc/themes/ant-dracula { };
}
