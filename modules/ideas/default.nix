{ pkgs, ... }: {
  home.packages = with pkgs; [
    # idea-community
    (jetbrains.idea-ultimate.overrideAttrs rec {
      version = "2024.1.4";
      src = fetchurl {
        url = "https://download-cf.jetbrains.com/idea/ideaIU-${version}.tar.gz";
        sha256 = "cda20bbbc052c2b8e87ea8607235ee0f7b5775728e8648c0a603889a3efa685f";
      };
    })
    (jetbrains.rider.overrideAttrs rec {
      version = "2024.1.4";
      src = fetchurl {
        url = "https://download-cf.jetbrains.com/rider/JetBrains.Rider-${version}.tar.gz";
        sha256 = "e277c2636383c023f00bd7833be86ffe1f8f67cf98cb719bbb4293aa42ba8ad0";
      };
    })
  ];

  systemd.user.timers."remover_licens" = {
    Install.WantedBy = [ "timers.target" ];
    Timer =
      {
        OnCalendar = "*-*-2,18 15:00:00";
        Persistent = "true";
        Unit = "remover_licens";
      };
  };


  systemd.user.services."remover_licens" = {
    Unit = {
      Description = "Remove license jetbrains product";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "exec";
      ExecStart = ./remove_license.sh;
    };
  };
}
