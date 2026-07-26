{ pkgs, ... }:
let
  theme = import ../../themes/bloom.nix;
  c = theme.colors;
  # Private family photo kept outside this public repository.
  wallpaper = "/home/jwlee/Pictures/Wallpapers/family-portrait.jpg";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # This configuration uses Hyprlang-style variables and bind strings.
    # Home Manager 26.05 otherwise defaults new installations to Lua.
    configType = "hyprlang";
    systemd.enable = false; # UWSM owns the graphical session.
    settings = {
      "$mainMod" = "SUPER";
      # Native 1920x1080 with no UI scaling for maximum usable workspace.
      monitor = "eDP-1,preferred,auto,1";

      exec-once = [
        "fcitx5 -d --replace"
        "nm-applet --indicator"
        "blueman-applet"
        "hyprctl setcursor Bibata-Modern-Ice 22"
      ];

      input = {
        kb_layout = "kr";
        kb_variant = "kr104";
        follow_mouse = 1;
        repeat_delay = 300;
        repeat_rate = 35;
        touchpad = {
          tap-to-click = true;
          natural_scroll = false;
          disable_while_typing = true;
        };
      };

      general = {
        gaps_in = 7;
        gaps_out = 16;
        border_size = 2;
        "col.active_border" = "rgb(${c.accent})";
        "col.inactive_border" = "rgba(${c.muted}66)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 9;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 0.97;
        fullscreen_opacity = 1.0;
        blur.enabled = false;
        shadow = {
          enabled = true;
          range = 14;
          render_power = 3;
          color = "rgba(00000066)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOut, 0.16, 1, 0.3, 1"
          "easeInOut, 0.65, 0, 0.35, 1"
        ];
        animation = [
          "windows, 1, 3, easeOut, slide"
          "windowsOut, 1, 2, easeInOut, popin 90%"
          "border, 1, 4, easeOut"
          "fade, 1, 3, easeOut"
          "workspaces, 1, 3, easeOut, slide"
        ];
      };

      dwindle = {
        preserve_split = true;
        smart_split = false;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
      };

      bind = [
        "$mainMod, T, exec, foot"
        "$mainMod, B, exec, google-chrome-stable"
        "$mainMod, E, exec, thunar"
        "$mainMod, SPACE, exec, rofi -show drun"
        "$mainMod, Q, killactive"
        "$mainMod SHIFT, Q, exit"
        "$mainMod, F, fullscreen"
        "$mainMod, V, togglefloating"
        "$mainMod, P, pseudo"
        "$mainMod, J, layoutmsg, togglesplit"
        "$mainMod, L, exec, loginctl lock-session"
        "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mainMod, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ] ++ (builtins.concatLists (builtins.genList (i:
        let ws = i + 1; in [
          "$mainMod, code:1${toString i}, workspace, ${toString ws}"
          "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
        ]) 9));

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      wallpaper = [{
        monitor = "eDP-1";
        path = "${wallpaper}";
        fit_mode = "cover";
      }];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [{
        path = "${wallpaper}";
        blur_passes = 1;
        blur_size = 4;
        brightness = 0.55;
      }];
      input-field = [{
        size = "290, 48";
        position = "0, -70";
        halign = "center";
        valign = "center";
        outline_thickness = 2;
        outer_color = "rgb(${c.accent})";
        inner_color = "rgb(${c.surface})";
        font_color = "rgb(${c.foreground})";
        placeholder_text = "Password";
        dots_center = true;
        rounding = 8;
      }];
      label = [{
        text = "$TIME";
        color = "rgb(${c.foreground})";
        font_family = theme.fonts.ui;
        font_size = 56;
        position = "0, 55";
        halign = "center";
        valign = "center";
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "loginctl lock-session"; }
        { timeout = 600; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
        { timeout = 1200; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-width = 360;
      control-center-margin-top = 12;
      control-center-margin-right = 12;
      notification-window-width = 360;
      notification-icon-size = 42;
      timeout = 6;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = true;
      keyboard-shortcuts = true;
      widgets = [ "title" "dnd" "notifications" "mpris" ];
    };
    style = ''
      * {
        font-family: "${theme.fonts.ui}", "Noto Sans CJK KR", sans-serif;
        font-size: 12px;
      }
      .control-center {
        background: #${c.background};
        color: #${c.foreground};
        border: 1px solid #${c.surfaceRaised};
        border-radius: 10px;
      }
      .notification-row { outline: none; }
      .notification {
        background: #${c.surface};
        color: #${c.foreground};
        border: 1px solid #${c.surfaceRaised};
        border-radius: 9px;
        margin: 6px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.35);
      }
      .notification-content { padding: 10px; }
      .summary { font-weight: 600; }
      .body { color: #${c.muted}; }
      .critical { border-color: #${c.urgent}; }
      .widget-title { color: #${c.accent}; margin: 10px; }
      .widget-dnd { margin: 0 10px 10px; }
      .widget-mpris { background: #${c.surface}; border-radius: 8px; margin: 6px; }
    '';
  };
  services.cliphist.enable = true;

  home.packages = with pkgs; [
    cliphist
    hyprpaper
    swaynotificationcenter
  ];
}
