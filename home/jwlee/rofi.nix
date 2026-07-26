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
      bloom-bg: #${c.background};
      bloom-surface: #${c.surface};
      bloom-raised: #${c.surfaceRaised};
      bloom-fg: #${c.foreground};
      bloom-muted: #${c.muted};
      bloom-accent: #${c.accent};
      background-color: transparent;
      text-color: @bloom-fg;
    }

    window {
      width: 600px;
      border: 2px;
      border-color: @bloom-accent;
      border-radius: 10px;
      background-color: @bloom-bg;
      padding: 14px;
    }

    mainbox {
      spacing: 12px;
      background-color: transparent;
    }

    inputbar {
      children: [ prompt, entry ];
      spacing: 10px;
      padding: 11px 13px;
      border-radius: 7px;
      background-color: @bloom-surface;
    }

    prompt {
      background-color: transparent;
      text-color: @bloom-accent;
    }

    entry {
      background-color: transparent;
      text-color: @bloom-fg;
      placeholder: "Type to search";
      placeholder-color: @bloom-muted;
    }

    listview {
      lines: 8;
      columns: 1;
      fixed-height: false;
      scrollbar: false;
      spacing: 4px;
      background-color: transparent;
    }

    element {
      padding: 9px 11px;
      spacing: 12px;
      border-radius: 7px;
      background-color: transparent;
      text-color: @bloom-fg;
    }

    element selected.normal {
      background-color: @bloom-raised;
      text-color: @bloom-fg;
    }

    element-icon {
      size: 24px;
      background-color: transparent;
    }

    element-text {
      vertical-align: 0.5;
      background-color: transparent;
      text-color: inherit;
    }

    message, textbox {
      background-color: transparent;
      text-color: @bloom-muted;
    }
  '';
}
