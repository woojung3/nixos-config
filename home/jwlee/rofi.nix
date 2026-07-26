{ pkgs, ... }:
let
  theme = import ../../themes/bloom.nix;
  c = theme.colors;
in
{
  home.packages = [ pkgs.rofi ];

  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run,window";
      show-icons: true;
      display-drun: "Applications";
      display-run: "Command";
      display-window: "Windows";
      drun-display-format: "{name}";
      font: "${theme.fonts.ui} 11";
      terminal: "foot";
      matching: "fuzzy";
      sorting-method: "fzf";
      sort: true;
    }
    @theme "bloom"
  '';

  xdg.configFile."rofi/themes/bloom.rasi".text = ''
    * {
      background: #${c.background};
      surface: #${c.surface};
      raised: #${c.surfaceRaised};
      foreground: #${c.foreground};
      muted: #${c.muted};
      accent: #${c.accent};
    }

    window {
      width: 580px;
      border: 2px;
      border-color: @accent;
      border-radius: 10px;
      background-color: @background;
      padding: 14px;
    }

    mainbox { spacing: 12px; }

    inputbar {
      children: [ prompt, entry ];
      spacing: 10px;
      padding: 11px 13px;
      border-radius: 7px;
      background-color: @surface;
    }

    prompt { color: @accent; }
    entry { placeholder: "Type to search"; placeholder-color: @muted; }

    listview {
      lines: 8;
      columns: 1;
      fixed-height: false;
      scrollbar: false;
      spacing: 4px;
    }

    element {
      padding: 9px 11px;
      spacing: 12px;
      border-radius: 7px;
      background-color: transparent;
      text-color: @foreground;
    }

    element selected.normal {
      background-color: @raised;
      text-color: @foreground;
    }

    element-icon { size: 24px; background-color: transparent; }
    element-text { vertical-align: 0.5; background-color: transparent; }
  '';
}
