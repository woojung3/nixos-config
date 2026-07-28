{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Daily applications
    google-chrome
    obsidian
    mousepad
    smplayer
    mpv
    baobab

    # Desktop integration
    blueman
    pavucontrol
    networkmanagerapplet
    file-roller
    libnotify
    brightnessctl
    playerctl
    wl-clipboard
    grim
    slurp
    swappy

    # Archives and files
    unzip
    zip
    unar

    # Basic development tooling; project runtimes belong in devShells.
    gcc
    gnumake
    cmake
    pkg-config
    clang-tools
    nodejs
  ];
}
