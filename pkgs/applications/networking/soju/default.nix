{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "soju";
  version = "5e2910ba9dea0336e3a2aa227728aff9af6795ae";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = pname;
    rev = version;
    hash = "sha256-znBPQoILDOA2cHxoGO4YRY4Gg0uNqcCkFnvrap8MtxA=";
  };
  modSha256 = "sha256-fjtNmP90ZecOJRlecD8rannPo5kOlFE/8hD96E9xhnY=";

  subPackages = [ "cmd/soju" "cmd/sojuctl" ];

  meta = with stdenv.lib; {
    description = "A user-friendly IRC bouncer.";
    homepage = "https://sr.ht/~emersion/soju/";
    license = licenses.agpl3Plus;
  };
}
