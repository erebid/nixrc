{ stdenv, fetchurl, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  pname = "ant-dracula-theme";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/EliverLara/Ant-Dracula/releases/download/v${version}/Ant-Dracula.tar";
    hash = "sha256-bVb//ysgNcvglq0MuFaEptHbw3eU43/YRB5f1ZPhaAE=";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/Ant-Dracula
    cp -a * $out/share/themes/Ant-Dracula
    rm -r $out/share/themes/Ant-Dracula/{Art,LICENSE,README.md,gtk-2.0/render-assets.sh}
    runHook postInstall
  '';

  outputHashMode = "recursive";
  outputHash = "sha256-mjhCBoFKWNDzQJ+v/lQvzuEBFhvP7JRoXRY47TFzjHc=";

  meta = with stdenv.lib; {
    description = "A flat and light theme with a modern look";
    homepage = https://github.com/EliverLara/Ant-Dracula;
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = [
      maintainers.pbogdan
    ];
  };
}
