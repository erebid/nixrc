final: prev: {
  gamemode = prev.callPackage ./os-specific/linux/gamemode { };
  libinih = prev.callPackage ./development/libraries/libinih { };
}
