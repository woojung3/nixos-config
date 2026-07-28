{ ... }:
let
  theme = import ../../themes/bloom.nix;
  c = theme.colors;
in
{
  programs.waybar = {
    enable = true;
    # Hyprland starts Waybar early so the first desktop frame is already complete.
    systemd.enable = false;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 34;
      margin-top = 10;
      margin-left = 14;
      margin-right = 14;
      spacing = 0;

      modules-left = [ "custom/launcher" "hyprland/window" ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [ "tray" "wireplumber" "backlight" "battery" "clock" "custom/power" ];

      "custom/launcher" = {
        format = "❁";
        tooltip-format = "Applications";
        on-click = "rofi -show drun";
      };

      "hyprland/window" = {
        format = "{title}";
        max-length = 42;
        separate-outputs = true;
      };

      "hyprland/workspaces" = {
        format = "{id}";
        persistent-workspaces = { "*" = 5; };
        on-click = "activate";
      };

      tray = {
        icon-size = 15;
        spacing = 8;
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰖁 —";
        format-icons = [ "" "" "" ];
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
      };

      backlight = {
        format = " {percent}%";
        on-scroll-up = "brightnessctl set 5%+";
        on-scroll-down = "brightnessctl set 5%-";
      };

      battery = {
        interval = 30;
        states = { warning = 25; critical = 12; };
        format = "{icon} {capacity}%";
        format-icons = [ "" "" "" "" "" ];
        format-charging = "󰂄 {capacity}%";
        tooltip-format = "{timeTo} · {power:.1f} W";
      };

      clock = {
        interval = 30;
        format = "{:%a %d · %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          weeks-pos = "right";
        };
      };

      "custom/power" = {
        format = "";
        tooltip-format = "Power menu";
        on-click = "power-menu";
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: "${theme.fonts.ui}", "Symbols Nerd Font", "Noto Sans CJK KR", sans-serif;
        font-size: 12px;
        font-weight: 500;
      }

      window#waybar {
        background: transparent;
        color: #${c.foreground};
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: #${c.background};
        border: 1px solid #${c.surfaceRaised};
        border-radius: 10px;
        box-shadow: 0 3px 14px rgba(0, 0, 0, 0.32);
      }

      #custom-launcher {
        padding: 0 12px;
        color: #${c.accent};
        font-size: 16px;
        font-weight: 600;
      }

      #window {
        padding: 0 13px 0 5px;
        color: #${c.muted};
      }

      window#waybar.empty #window {
        padding: 0;
      }

      #workspaces {
        padding: 3px 5px;
      }

      #workspaces button {
        min-width: 27px;
        padding: 0 7px;
        border-radius: 7px;
        color: #${c.muted};
        background: transparent;
      }

      #workspaces button:hover {
        color: #${c.foreground};
        background: #${c.surfaceRaised};
      }

      #workspaces button.active {
        color: #${c.background};
        background: #${c.accent};
      }

      #workspaces button.urgent {
        color: #${c.background};
        background: #${c.urgent};
      }

      #tray,
      #wireplumber,
      #backlight,
      #battery,
      #clock {
        padding: 0 10px;
        color: #${c.foreground};
      }

      #tray,
      #wireplumber,
      #backlight,
      #battery,
      #clock {
        border-right: 1px solid #${c.surfaceRaised};
      }

      #custom-power {
        padding: 0 12px;
        color: #${c.accent};
        font-size: 15px;
      }

      #custom-power:hover { color: #${c.foreground}; }
      #battery.warning { color: #${c.accentSoft}; }
      #battery.critical { color: #${c.urgent}; }

      tooltip {
        background: #${c.background};
        color: #${c.foreground};
        border: 1px solid #${c.surfaceRaised};
        border-radius: 8px;
      }
    '';
  };
}
