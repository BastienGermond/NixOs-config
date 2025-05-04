{
  lib,
  config,
  infra,
  ...
}: let
  anemone = infra.hosts.anemone;
in
  lib.mkMerge [
    {
      services.komf = {
        port = anemone.ports.komf;

        group = "manga";

        komga = {
          uri = "https://komga.germond.org";
          user = "komf@germond.org";
          passwordFile = config.sops.secrets.KomfApiKey.path;
        };

        settings = {
          komga = {
            eventListener = {
              enabled = true;
            };
            metadataUpdate = {
              default = {
                libraryType = "MANGA";
                updateModes = ["API" "COMIC_INFO"];
                aggregate = true;
                mergeTags = true;
                mergeGenres = true;
                bookCovers = true;
                seriesCovers = true;
                overrideExistingCovers = true;
                overrideComicInfo = true;
                postProcessing = {
                  seriesTitle = true;
                  seriesTitleLanguage = "en";
                  fallbackToAltTitle = true;
                  alternativeSeriesTitles = true;
                  alternativeSeriesTitleLanguages = ["en"];
                  orderBooks = true;
                  scoreTagName = true;
                };
              };
            };
          };
          metadataProviders = {
            defaultProviders = {
              mangaUpdates = {
                priority = 10;
                enabled = true;
                mediaType = "MANGA";
                authorRoles = ["WRITER"];
                artistRoles = ["PENCILLER" "INKER" "COLORIST" "LETTERER" "COVER"];
              };
              mangaDex = {
                priority = 90;
                enabled = true;
                coverLanguages = ["en"];
              };
            };
          };
        };
      };
    }

    (lib.mkIf config.services.komf.enable {
      networking.firewall.allowedTCPPorts = [anemone.ports.komf];
    })
  ]
