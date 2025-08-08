{...}: {
  xdg.enable = true;

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
      "text/html" = ["librewolf.desktop"];
      "x-scheme-handler/http" = ["librewolf.desktop"];
      "x-scheme-handler/https" = ["librewolf.desktop"];
      "x-scheme-handler/about" = ["librewolf.desktop"];
      "x-scheme-handler/unknown" = ["librewolf.desktop"];
    };
    defaultApplications = {
      "application/pdf" = "org.gnome.Evince.desktop";
      "text/html" = ["librewolf.desktop"];
      "x-scheme-handler/http" = ["librewolf.desktop"];
      "x-scheme-handler/https" = ["librewolf.desktop"];
      "x-scheme-handler/about" = ["librewolf.desktop"];
      "x-scheme-handler/unknown" = ["librewolf.desktop"];
    };
  };

  xdg.desktopEntries = {
    librewolf = {
      name = "Librewolf";
      genericName = "Web Browser";
      exec = "librewolf %U";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" "application/pdf" ];
    };
  };

  xdg.userDirs = {
    download = "\$HOME/Downloads";
    desktop = "\$HOME";
    documents = "\$HOME/Documents";
    music = "\$HOME/Music";
    pictures = "\$HOME/Pictures";
    templates = "\$HOME";
    videos = "\$HOME/Videos";
  };

  xdg.configFile = {
    "git/config".source = ../dotfiles/gitconfig;
    "signature".source = ../dotfiles/signature;
  };

  xdg.configFile."mimeapps.list".force = true;
}
