{ pkgs, lib, python38Packages }:

with python38Packages;

buildPythonApplication rec {
  pname = "spotibar";
  version = "0.2.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "449f83ee0d604b441e4c3ef345e09e68995941e1fdd4d0be45a2b029ca7372c2";
  };

  propagatedBuildInputs = [ setuptools tkinter pylast spotipy ];

  # There are no tests
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/conor-f/spotibar";
    description = "Polybar plugin for Spotify that uses the Spotify Web API.";
    license = licenses.unlicense;
    platforms = platforms.unix;
  };
}
