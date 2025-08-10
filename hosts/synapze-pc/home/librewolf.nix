{...}:
{
  programs.librewolf = {
    enable = true;
    settings = {
      "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "layout.css.devPixelsPerPx" = 1.25;
    };
  };
}
