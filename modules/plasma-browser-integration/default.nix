{ pkgs, ... }: {
  home.packages = with pkgs; [ kdePackages.plasma-browser-integration ];

  home.file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
    "${pkgs.kdePackages.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
