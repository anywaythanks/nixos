{ pkgs, ... }:
let
  curr_user = "any";
  homedir = "/home/${user}";
in
{
  services.syncthing = {
    enable = true;
    user = curr_user;
    group = "users";
    configDir = "${homedir}/.config/syncthing";

    settings.gui.user = "any";
    #mkpasswd -m sha-512
    settings.gui.password = "$6$r.EkkAjea263VQg6$QlzQRC7CacrAz8t8rFSEx4OnqDP5V3qwXrHVjjA8Zm1qujBWEndz19Jjx0Igc15w5LT20EEUmH9JFCsJn6G3n.";

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "laptop" = { id = "Q3AM2FX"; };
      };
      folders = {
        "s4auq-slx1x" = {
          path = "${homedir}/sync";
          devices = [ "laptop" ];
        };
        "programming" = {
          path = "${homedir}/programming";
          devices = [ "laptop" ];
        };
        "ooynn-zyes3" = {
          path = "${homedir}/other/mad";
          devices = [ "laptop" ];
        };
      };
    };
  };
}
