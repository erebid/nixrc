{ stdenv, buildGoModule, fetchgit }:
buildGoModule rec {
  name = "bloat";

  src = fetchgit {
    url = "https://git.freesoftwareextremist.com/bloat/";
    rev = "61020d8837745f4b1632bd31e54017abeff7862a";
    sha256 = "sha256-pk1vgrid21dAVlRAy3nz+PG/xc/0UmA6J7RwstxRA6Q=";
  };

  vendorSha256 = null;

  meta = with stdenv.lib; {
    description = "A web client for Mastodon Network";
    homepage = "https://git.freesoftwareextremist.com/bloat/";
    license = licenses.cc0;
  };
}
