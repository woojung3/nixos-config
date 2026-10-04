{ lib, pkgs, ... }:
let
  brightnessControl = pkgs.writeShellApplication {
    name = "brightness-control";
    runtimeInputs = [ pkgs.brightnessctl ];
    text = builtins.readFile ./quickshell/scripts/brightness-control.sh;
  };
  powerAction = pkgs.writeShellApplication {
    name = "bloom-power-action";
    runtimeInputs = [
      pkgs.systemd
      pkgs.uwsm
    ];
    text = builtins.readFile ./quickshell/scripts/power-action.sh;
  };
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [ pkgs.quickshell ];
    text = ''
      quickshell -c bloom ipc call power toggle
    '';
  };

  # One registry drives both deployment and local QML type registration.
  components = [
    "BatteryPanel"
    "BloomButton"
    "BloomSlider"
    "BrightnessPanel"
    "CalendarPanel"
    "ChoicePicker"
    "MediaIconButton"
    "NowPlaying"
    "PanelHost"
    "PanelSession"
    "PowerPanel"
    "SoundPanel"
  ];
  files = [
    "shell.qml"
    "BatteryInfo.js"
    "CalendarMath.js"
    "SoundLogic.js"
  ]
  ++ map (name: "${name}.qml") components;
in
{
  home.packages = [
    pkgs.quickshell
    brightnessControl
    powerAction
    powerMenu
  ];

  xdg.configFile =
    builtins.listToAttrs (
      map (file: {
        name = "quickshell/bloom/${file}";
        value.source = ./quickshell + "/${file}";
      }) files
    )
    // {
      "quickshell/bloom/Theme.qml".text = import ./quickshell/theme.nix;
      "quickshell/bloom/Commands.qml".text = ''
        pragma Singleton
        import QtQuick
        QtObject {
          readonly property string brightness: "${brightnessControl}/bin/brightness-control"
          readonly property string power: "${powerAction}/bin/bloom-power-action"
          readonly property string powerProfiles: "${pkgs.power-profiles-daemon}/bin/powerprofilesctl"
        }
      '';
      "quickshell/bloom/qmldir".text = ''
        singleton Theme 1.0 Theme.qml
        singleton Commands 1.0 Commands.qml
      ''
      + lib.concatMapStringsSep "\n" (name: "${name} 1.0 ${name}.qml") components
      + "\n";
    };
}
