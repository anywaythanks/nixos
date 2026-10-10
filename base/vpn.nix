{ config, pkgs, ... }:

let
  # Ваш сгенерированный HWID
  myHwid =  builtins.readFile ~/secret/hwid;
  subscriptionUrl = builtins.readFile ~/secret/subscribe;
  singboxConfig = "/etc/sing-box/config.json";
in
{
  services.sing-box = {
    enable = true;
    settings = {
      log = { loglevel = "warn"; };
      inbounds = [{
        port = 10808;
        listen = "127.0.0.1";
        protocol = "socks";
        settings = { udp = true; auth = "noauth"; };
      }];
    };
    configFile = singboxConfig;
  };

  systemd.services.singbox-subscription-updater = {
    description = "Update sing-box config from subscription with HWID";
    path = [ pkgs.sing-box pkgs.curl pkgs.jq pkgs.coreutils ];
    script = ''
      set -euo pipefail
      tmp=$(mktemp)

      #    (в будущем, когда sing-box получит нативную поддержку, эта часть упростится)
      #    Пока используем curl, так как он надежнее для этой задачи.
      curl -fsSL \
        -A "v2rayNG/1.8.5" \
        -H "x-hwid: ${myHwid}" \
        -H "x-device-os: NixOS" \
        -H "x-ver-os: 25.05" \
        -H "x-device-model: Custom-PC" \
        "${subscriptionUrl}" -o "$tmp"

      if ! jq -e 'type == "array" and length > 0' "$tmp" >/dev/null; then
        echo "ERROR: Invalid config received from subscription." >&2
        cat "$tmp" >&2
        rm -f "$tmp"
        exit 1
      fi

      install -m 0600 "$tmp" ${singboxConfig}
      rm -f "$tmp"
      systemctl restart sing-box
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      # Разрешаем сервису писать в /etc/sing-box
      ReadWritePaths = [ "/etc/sing-box" ];
    };
  };

  systemd.timers.singbox-subscription-updater = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "6h";
      Persistent = true;
    };
  };
}