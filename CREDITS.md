# Credits and provenance

This configuration was written for `jwlaptop` and incorporates ideas and
assets from the following public dotfiles projects.

## 0xTux NixOS configuration

- Source: <https://github.com/0xTux/nixos-config>
- License: GPL-3.0
- Used as an architectural and compositional reference for a sparse Hyprland
  desktop and a flake-based NixOS installation.

## ComplexPlatform KDE dotfiles

- Source: <https://github.com/ComplexPlatform/KDE-dotfiles>
- License: GPL-3.0
- `assets/wallpapers/flowers.jpg` is copied from `walls/flowers.jpg`.
- The Flowers screenshot informed the Bloom palette and wallpaper-led visual
  direction. KDE components from that project are not installed.

## elenapan dotfiles

- Source: <https://github.com/elenapan/dotfiles>
- License: GPL-2.0
- Used only as a visual reference for restrained, playful widgets. No source
  from this project is copied into this GPL-3.0 configuration.

## conrad-mo Hyprland dotfiles

- Source: <https://github.com/conrad-mo/hyprland-dot>
- No license is identified for the referenced material.
- Used as visual inspiration only; no files or source were copied.

## AmadeusWM Hyprland Winter

- Source: <https://github.com/AmadeusWM/hyprland-winter>
- Visual reference for workspace typography and the `一 二 三 四 五 六 七 八 九 〇`
  label sequence. Its Eww implementation and font files are not bundled.

## vdawg-git space_dots — Golden Era

- Source: <https://github.com/vdawg-git/space_dots>
- Visual reference for CRT curvature, scanlines and warm phosphor colors.
- Bloom's shader and toggle are implemented locally; the upstream shader,
  media and theme assets are not bundled.

## Qylock

- Source: <https://github.com/Darkkal44/qylock>
- License: GPL-3.0
- Used through a pinned flake input to provide the SDDM `pixel-munchlax` login
  theme. Its Quickshell lock screen is disabled.
- Qylock's bundled artwork retains its upstream provenance as documented by
  that project.

The full repository is distributed under GPL-3.0. Individual packaged software,
fonts, icons, and applications retain their respective upstream licenses.
