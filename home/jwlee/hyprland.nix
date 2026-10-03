{ pkgs, ... }:
let
  theme = import ../../themes/bloom.nix;
  c = theme.colors;
  # Private photos kept outside this public repository.
  wallpapers = {
    glenCanyon = "/home/jwlee/Pictures/Wallpapers/glen-canyon.jpg";
    family = "/home/jwlee/Pictures/Wallpapers/family-portrait.jpg";
    jirisanSunrise = "/home/jwlee/Pictures/Wallpapers/jirisan-cheonwangbong-sunrise.jpg";
    yeouido = "/home/jwlee/Pictures/Wallpapers/yeouido.jpg";
    grandCanyon = "/home/jwlee/Pictures/Wallpapers/grand-canyon.jpg";
  };
  suspendOnBattery = pkgs.writeShellApplication {
    name = "suspend-on-battery";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      # Do not suspend when any external power supply is online.
      for supply in /sys/class/power_supply/*; do
        if [[ -r "$supply/online" ]] && [[ "$(< "$supply/online")" == 1 ]]; then
          exit 0
        fi
      done

      # Require positive evidence of battery use; unknown state is a no-op.
      for supply in /sys/class/power_supply/*; do
        if [[ -r "$supply/type" && -r "$supply/status" ]] &&
           [[ "$(< "$supply/type")" == Battery && "$(< "$supply/status")" == Discharging ]]; then
          systemctl suspend
          exit 0
        fi
      done
    '';
  };
  workspaceWallpaper = pkgs.writeShellApplication {
    name = "workspace-wallpaper";
    runtimeInputs = [
      pkgs.awww
      pkgs.hyprland
      pkgs.jq
      pkgs.socat
    ];
    text = ''
      declare -A current_paths=()

      wallpaper_for_workspace() {
        case "$1" in
          1|6) printf '%s\n' ${wallpapers.glenCanyon} ;;
          2|7) printf '%s\n' ${wallpapers.family} ;;
          3|8) printf '%s\n' ${wallpapers.jirisanSunrise} ;;
          4|9) printf '%s\n' ${wallpapers.yeouido} ;;
          5|10) printf '%s\n' ${wallpapers.grandCanyon} ;;
          *) printf '%s\n' ${wallpapers.family} ;;
        esac
      }

      set_wallpaper() {
        local output="$1"
        local workspace="$2"
        local path
        path="$(wallpaper_for_workspace "$workspace")"

        if [[ "''${current_paths[$output]:-}" == "$path" ]]; then
          return
        fi

        # The daemon and a newly connected output may need a moment to become
        # ready. Keep wallpaper state independently for every monitor.
        for _ in {1..20}; do
          if awww img --outputs "$output" --resize crop \
            --transition-type fade --transition-duration 0.25 \
            --transition-fps 60 "$path" >/dev/null 2>&1; then
            current_paths[$output]="$path"
            return
          fi
          sleep 0.05
        done
      }

      refresh_wallpapers() {
        while IFS=$'\t' read -r output workspace; do
          set_wallpaper "$output" "$workspace"
        done < <(
          hyprctl monitors -j | jq -r \
            '.[] | [.name, (.activeWorkspace.id | tostring)] | @tsv'
        )
      }

      refresh_wallpapers

      socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
      socat -U - "UNIX-CONNECT:$socket" | while IFS= read -r event; do
        case "$event" in
          monitor*)
            # A reconnected output needs its image sent again, even when it
            # displays the same workspace as before disconnection.
            current_paths=()
            refresh_wallpapers
            ;;
          workspace*)
            refresh_wallpapers
            ;;
        esac
      done
    '';
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland and its portal are provided by the NixOS modules.
    package = null;
    portalPackage = null;
    # This configuration uses Hyprlang-style variables and bind strings.
    # Home Manager 26.05 otherwise defaults new installations to Lua.
    configType = "hyprlang";
    systemd.enable = false; # UWSM owns the graphical session.
    settings = {
      "$mainMod" = "SUPER";
      # Keep both displays at a smooth 60 Hz. The HDMI sink advertises 4K as
      # preferred, but this laptop can only drive that mode at 30 Hz.
      monitor = [
        "eDP-1,1920x1080@60,0x0,1"
        "HDMI-A-1,1920x1080@60,1920x0,1"
      ];

      # Workspaces 1-5 belong to the laptop and 6-10 to the external display.
      # Persistent workspaces also keep all ten visible in Waybar.
      workspace =
        (map (ws: "${toString ws}, monitor:eDP-1, persistent:true") [
          1
          2
          3
          4
          5
        ])
        ++ (map (ws: "${toString ws}, monitor:HDMI-A-1, persistent:true") [
          6
          7
          8
          9
          10
        ]);

      # Set the compositor cursor before its first frame instead of changing it
      # asynchronously with exec-once.
      env = [
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "XCURSOR_SIZE,22"
      ];

      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "nm-applet --indicator"
        "blueman-applet"
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

      windowrule = [
        {
          name = "mousepad-float";
          "match:class" = "^org\\.xfce\\.mousepad$";
          float = "on";
          center = "on";
          size = "520 500";
        }
        {
          name = "thunar-float";
          "match:class" = "^thunar$";
          float = "on";
          center = "on";
          size = "680 500";
        }
      ];

      bind = [
        "$mainMod, T, exec, foot"
        "$mainMod, B, exec, google-chrome-stable"
        "$mainMod, E, exec, thunar"
        "$mainMod, N, exec, ${pkgs.mousepad}/bin/mousepad"
        "$mainMod, SPACE, exec, rofi -show drun"
        "$mainMod, Q, killactive"
        "ALT, F4, killactive"
        "$mainMod, F, fullscreen"
        "$mainMod, V, togglefloating"
        "$mainMod, P, pseudo"
        "$mainMod, J, layoutmsg, togglesplit"
        "$mainMod, L, exec, loginctl lock-session"
        "$mainMod, ESCAPE, exec, power-menu"
        "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mainMod, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        "ALT, TAB, cyclenext"
        "ALT, TAB, bringactivetotop"
        "ALT SHIFT, TAB, cyclenext, prev"
        "ALT SHIFT, TAB, bringactivetotop"

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
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
            # Number-row keycodes are 10-18 for 1-9 and 19 for 0.
            keycode = if ws == 10 then 19 else 9 + ws;
          in
          [
            "$mainMod, code:${toString keycode}, workspace, ${toString ws}"
            "$mainMod SHIFT, code:${toString keycode}, movetoworkspace, ${toString ws}"
          ]
        ) 10
      ));

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

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [{
        path = "${wallpapers.family}";
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
        { timeout = 1200; on-timeout = "${suspendOnBattery}/bin/suspend-on-battery"; }
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

  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Screenshots
    save_filename_format=screenshot-%Y%m%d-%H%M%S.png
    early_exit=true
    auto_save=false
  '';

  systemd.user.services = {
    awww = {
      Unit = {
        Description = "Animated Wayland wallpaper daemon";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        # The workspace service always selects every output's wallpaper, so
        # restoring awww's cache is redundant and requires an unavailable CLI
        # in the daemon service's PATH.
        ExecStart = "${pkgs.awww}/bin/awww-daemon --quiet --no-cache";
        Restart = "always";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    workspace-wallpaper = {
      Unit = {
        Description = "Switch the wallpaper with the active workspace";
        After = [ "graphical-session.target" "awww.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${workspaceWallpaper}/bin/workspace-wallpaper";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
