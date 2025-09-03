bash -c 'cat > ~/dotfiles/burpsuite-pro.nix << '\''EOF'\''
{ lib, stdenv, fetchurl, makeWrapper, jdk21, ... }:

stdenv.mkDerivation rec {
  pname = "burpsuite-pro";
  version = "2024.12.1";

  src = fetchurl {
    url = "https://portswigger.net/burp/releases/download?product=pro&version=${version}&type=jar";
    sha256 = "0sdcywcic77v5jh9xy6alq8vlmrv1400q9giql5s2ax6s4fygp1z";
  };

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/burpsuite-pro
    cp $src $out/share/burpsuite-pro/burpsuite_pro.jar
    
    makeWrapper ${jdk21}/bin/java $out/bin/burpsuite-pro \
      --add-flags "-jar $out/share/burpsuite-pro/burpsuite_pro.jar"
  '';

  meta = with lib; {
    description = "Burp Suite Pro";
    homepage = "https://portswigger.net/burp";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
EOF'
