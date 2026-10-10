{ config, pkgs, pkgsUnstable, lib, ... }:
let
  xrayEtc = "/etc/xray";
  xrayConfig = "${xrayEtc}/config.json";
  subsDir = "/home/any/subs";
  subsFile = "${subsDir}/subscription.json";
  selFile = "${subsDir}/selected";

  # ── Интерактивный выбор сервера ────────────────────────────────────
  choose-sub = pkgs.writeShellApplication {
    name = "choose-sub";
    runtimeInputs = [ pkgs.jq pkgs.coreutils pkgs.systemd ];
    text = ''
      SUB="${subsFile}"
      SEL="${selFile}"
      CFG="${xrayConfig}"

      if [ ! -r "$SUB" ]; then
        echo "Ошибка: нет $SUB" >&2
        echo "Запустите: sudo systemctl start xray-config-updater" >&2
        exit 1
      fi

      if ! jq -e 'type == "array" and length > 0' "$SUB" >/dev/null; then
        echo "Ошибка: $SUB не является непустым массивом" >&2
        exit 1
      fi

      echo "Доступные серверы:"
      jq -r 'to_entries[] | "  " + (.key|tostring) + ") " + (.value.remarks // .value.tag // ("server-" + (.key|tostring)))' "$SUB"

      read -rp "Выберите номер сервера: " idx

      if ! jq -e --argjson i "$idx" '.[$i] != null' "$SUB" >/dev/null 2>&1; then
        echo "Ошибка: неверный номер: $idx" >&2
        exit 1
      fi

      name=$(jq -r --argjson i "$idx" '.[$i].remarks // .[$i].tag // "server-\($i)"' "$SUB")
      printf '%s\n' "$idx" > "$SEL"
      echo "Выбран: [$idx] $name"

      tmp=$(mktemp)
      trap 'rm -f "$tmp"' EXIT
      jq --argjson i "$idx" '.[$i]' "$SUB" > "$tmp"
      sudo install -m 0600 "$tmp" "$CFG"
      sudo systemctl restart xray.service
      echo "Готово."
    '';
  };
in {
  environment.systemPackages = [ pkgsUnstable.xray pkgs.jq choose-sub ];

  systemd.tmpfiles.rules =
    [ "d ${xrayEtc} 0700 root root -" "d ${subsDir} 0755 any users -" ];

  # ── Апдейтер: скачивает подписку + применяет выбор ─────────────────
  systemd.services.xray-config-updater = {
    description = "Fetch subscription and apply current selection (Xray)";
    path = [ pkgs.curl pkgs.jq pkgs.coreutils ];
    script = ''
      set -uo pipefail

      HWID_FILE="/home/any/secret/hwid"
      SUB_FILE="/home/any/secret/subscribe"
      SUBS_JSON="${subsFile}"
      SEL_FILE="${selFile}"
      CFG="${xrayConfig}"

      # ── 1. Попытка скачать подписку ────────────────────────────────
      if [ -r "$HWID_FILE" ] && [ -r "$SUB_FILE" ]; then
        MY_HWID=$(tr -d '[:space:]' < "$HWID_FILE")
        SUB_URL=$(tr -d '[:space:]' < "$SUB_FILE")

        tmp=$(mktemp)
        if curl -fsSL \
          -A "v2rayNG/1.8.5" \
          -H "x-hwid: $MY_HWID" \
          -H "x-device-os: NixOS" \
          -H "x-ver-os: 25.05" \
          -H "x-device-model: Custom-PC" \
          "$SUB_URL" -o "$tmp"; then
          if jq -e 'type == "array" and length > 0' "$tmp" >/dev/null 2>&1; then
            install -m 0644 -o any -g users "$tmp" "$SUBS_JSON.new"
            mv -f "$SUBS_JSON.new" "$SUBS_JSON"
            echo "INFO: subscription.json обновлён"
          else
            echo "WARN: ответ не массив — оставляю старый subscription.json" >&2
          fi
        else
          echo "WARN: не удалось скачать подписку — оставляю старую" >&2
        fi
        rm -f "$tmp"
      fi

      # ── 2. Применение выбора ───────────────────────────────────────
      if [ ! -r "$SUBS_JSON" ]; then
        echo "WARN: нет $SUBS_JSON — нечего применять" >&2
        exit 0
      fi

      if [ -r "$SEL_FILE" ]; then
        IDX=$(tr -d '[:space:]' < "$SEL_FILE")
      else
        IDX=0
      fi

      if ! jq -e --argjson i "$IDX" '.[$i] != null' "$SUBS_JSON" >/dev/null 2>&1; then
        echo "WARN: индекс $IDX отсутствует, choose 0" >&2
        IDX=0
      fi

      tmp_norm=$(mktemp)
      trap 'rm -f "$tmp_norm"' EXIT
      jq --argjson i "$IDX" '.[$i]' "$SUBS_JSON" > "$tmp_norm"

      # Отсекаем заглушку
      if jq -e '.remarks // "" | test("App not supported")' "$tmp_norm" >/dev/null 2>&1; then
        echo "WARN: заглушка App not supported — не применяю" >&2
        exit 0
      fi

      if [ -f "$CFG" ] && cmp -s "$tmp_norm" "$CFG"; then
        echo "INFO: конфиг не изменился"
        exit 0
      fi

      install -m 0600 "$tmp_norm" "$CFG"
      echo "INFO: применён сервер [$IDX] — перезапускаю xray"
      systemctl restart xray.service
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ReadWritePaths = [ xrayEtc subsDir ];
      SuccessExitStatus = [ 0 1 ];
    };
  };

  systemd.timers.xray-config-updater = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "6h";
      Persistent = true;
    };
  };

  # ── Xray ───────────────────────────────────────────────────────────
  systemd.services.xray = {
    description = "Xray proxy service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xray}/bin/xray run -c ${xrayConfig}";
      Restart = "on-failure";
      RestartSec = "5s";
      User = "root";
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      DeviceAllow = [ "/dev/net/tun rw" ];
      DevicePolicy = "closed";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = false;
    };
  };

  # Встроенный модуль Xray отключаем, чтобы не было конфликта
  services.xray.enable = false;
}
