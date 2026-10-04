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
    ''
    + builtins.readFile ./crt/toggle.sh;
  };
in
{
  home.packages = [ toggle ];
  xdg.configFile."bloom/crt.frag".source = ./crt/bloom-crt.frag;

  # The effect is a session-only easter egg, never a persisted startup theme.
  wayland.windowManager.hyprland.settings.decoration.screen_shader = lib.mkDefault "";
  programs.waybar.settings.mainBar."custom/launcher".on-click-right =
    "${toggle}/bin/bloom-crt-toggle";
}
