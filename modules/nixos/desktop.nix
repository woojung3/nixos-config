{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd '${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop'";
      user = "greeter";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-hangul
      ];
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Native GTK Wayland applications use the Wayland text-input protocol.
    # Setting GTK_IM_MODULE makes Fcitx5 show a diagnostic on every login.
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  programs.dconf.enable = true;

  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      ibm-plex
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "IBM Plex Sans" "Noto Sans CJK KR" ];
      serif = [ "Noto Serif CJK KR" ];
      monospace = [ "JetBrains Mono" "Noto Sans Mono CJK KR" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
