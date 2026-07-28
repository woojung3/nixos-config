{ ... }:
let
  theme = import ../../themes/bloom.nix;
  c = theme.colors;
in
{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "${theme.fonts.mono}:size=11";
        pad = "12x12";
        term = "xterm-256color";
        selection-target = "clipboard";
      };
      "colors-dark" = {
        alpha = 0.88;
        background = c.background;
        foreground = c.foreground;
        cursor = "${c.background} ${c.accent}";
        regular0 = c.background;
        regular1 = c.urgent;
        regular2 = c.olive;
        regular3 = c.accentSoft;
        regular4 = c.secondary;
        regular5 = c.accent;
        regular6 = c.secondary;
        regular7 = c.foreground;
        bright0 = c.muted;
        bright1 = c.urgent;
        bright2 = c.olive;
        bright3 = c.accentSoft;
        bright4 = c.secondary;
        bright5 = c.accent;
        bright6 = c.secondary;
        bright7 = "ffffff";
      };
      cursor.blink = "yes";
      mouse.hide-when-typing = "yes";
      key-bindings = {
        clipboard-copy = "Control+Shift+c XF86Copy";
        clipboard-paste = "Control+Shift+v XF86Paste";
        search-start = "Control+Shift+r";
      };
    };
  };
}
