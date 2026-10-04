{
  config,
  lib,
  pkgs,
  ...
}:
let
  shaderPath = "${config.xdg.configHome}/bloom/crt.frag";
  toggle = pkgs.writeShellApplication {
    name = "bloom-crt-toggle";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.jq
      pkgs.util-linux
      pkgs.coreutils
    ];
    text = ''
      export BLOOM_CRT_SHADER=${lib.escapeShellArg shaderPath}
      export BLOOM_CRT_FULL_REDRAW=${if config.bloom.crt.fullRedraw then "1" else "0"}
    ''
    + builtins.readFile ./crt/toggle.sh;
  };
in
{
  options.bloom.crt.fullRedraw = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Redraw changed monitors in full while CRT is enabled to avoid curvature artifacts.";
  };

  config = {
    home.packages = [ toggle ];
    xdg.configFile."bloom/crt.frag".source = ./crt/bloom-crt.frag;

    # The effect is a session-only easter egg, never a persisted startup theme.
    wayland.windowManager.hyprland.settings.decoration.screen_shader = lib.mkDefault "";
    programs.waybar.settings.mainBar."custom/launcher".on-click-right =
      "${toggle}/bin/bloom-crt-toggle";
  };
}
