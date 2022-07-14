{ pkgs, lib, python39Packages }:

with python39Packages;

buildPythonApplication rec {
  pname = "spotibar";
  version = "0.2.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Hu3hfLqSBIAG9FtzUGal7kAD7GtwzqOP8yWgSfWv90s=";
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
