{
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;

    # Transparency/Opacity
    inactiveOpacity = 0.8;
    activeOpacity = 1;
    opacityRules = [
      "100:class_g   *?= 'Firefox'"
      "100:class_g   *?= 'Deadd-notification-center'"
      "100:class_g   *?= 'Rofi'"
    ];

    # Fading
    fade = false;

    # Shadows
    # shadow = true;
    # shadowExclude = [
    #   "class_g *?= 'Chromium-browser'"
    #   "class_g *?= 'Code'"
    #   "window_type = 'popup_menu'"
    # ];

    settings = {
      # Blur settings (correct structure)
      # blur = {
      #   method = "dual_kawase";
      #   strength = 8;
      #   # Exclude blur for popup menus
      #   exclude = [
      #     "window_type = 'popup_menu'"
      #     "class_g *?= 'Chromium-browser'"
      #     "class_g *?= 'Code'"
      #   ];
      # };

      # Window rounding
      corner-radius = 10;
      round-borders = 1;
      rounded-corners-exclude = [ "class_g = 'Custom-taffybar'" ];
    };
  };
}
