{ pkgs, ... }: {
  home.packages = with pkgs; [
    # idea-community
    (jetbrains.idea-ultimate.overrideAttrs rec {
      version = "2024.3.5";
      src = fetchurl {
        url = "https://download-cf.jetbrains.com/idea/ideaIU-${version}.tar.gz";
        sha256 = "f8e8e864f4fedddf1d366a7db23fc4132192c3a6029c614a382186ff564a78a1";
      };
    })
    (jetbrains.webstorm.overrideAttrs rec {
      version = "2024.3.5";
      src = fetchurl {
        url = "https://download-cf.jetbrains.com/webstorm/WebStorm-${version}.tar.gz";
        sha256 = "da587d7ca3ebb08f067143e4a6b35f1aa133aa10af7fc365496838006fcd1aed";
      };
    })
  ];

  systemd.user.timers."remover_licens" = {
    Install.WantedBy = [ "timers.target" ];
    Timer =
      {
        OnCalendar = "*-*-01 15:00:00";
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
