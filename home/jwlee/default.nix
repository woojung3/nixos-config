{ pkgs, ... }:
let
  theme = import ../../themes/bloom.nix;
in
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./rofi.nix
    ./terminal.nix
    ./shell.nix
    ./neovim.nix
  ];

  home = {
    username = "jwlee";
    homeDirectory = "/home/jwlee";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "google-chrome-stable";
      TERMINAL = "foot";
    };
    packages = with pkgs; [
      papirus-icon-theme
      bibata-cursors
      adw-gtk3
      jq
      ripgrep
      fd
      fzf
      bat
      eza
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "google-chrome.desktop" ];
        "x-scheme-handler/http" = [ "google-chrome.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];
        "video/mp4" = [ "smplayer.desktop" ];
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 22;
    };
    font = {
      name = theme.fonts.ui;
      size = 10;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    font-name = "${theme.fonts.ui} 10";
    document-font-name = "${theme.fonts.ui} 10";
    monospace-font-name = "${theme.fonts.mono} 10";
  };

  # Keep the Korean 104-key layout and make the physical Hangul key primary.
  xdg.configFile."fcitx5/config".text = ''
    [Hotkey]
    EnumerateWithTriggerKeys=True

    [Hotkey/TriggerKeys]
    0=Hangul
    1=Control+space

    [Behavior]
    ActiveByDefault=False
    ShareInputState=No
    PreeditEnabledByDefault=True
    ShowInputMethodInformation=True
  '';

  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=Default
    Default Layout=kr
    DefaultIM=keyboard-kr

    [Groups/0/Items/0]
    Name=keyboard-kr
    Layout=kr

    [Groups/0/Items/1]
    Name=hangul
    Layout=kr

    [GroupOrder]
    0=Default
  '';

  programs.home-manager.enable = true;
}
