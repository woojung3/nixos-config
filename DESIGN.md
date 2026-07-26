# jwlaptop visual direction

## Design statement

A quiet, polished desktop that is minimal without looking generic: restrained structure, deliberate proportions, a wallpaper-led palette, and a small amount of discreet playfulness.

## Primary references

- [0xTux/nixos-config](https://github.com/0xTux/nixos-config) — sparse Hyprland composition and NixOS implementation (GPL-3.0)
- [ComplexPlatform/KDE-dotfiles — Flowers](https://github.com/ComplexPlatform/KDE-dotfiles) — cohesive wallpaper-derived palette and visual hierarchy (GPL-3.0)
- [elenapan/dotfiles](https://github.com/elenapan/dotfiles) — secondary reference for restrained, cute widgets (GPL-2.0)
- [conrad-mo/hyprland-dot](https://github.com/conrad-mo/hyprland-dot) — visual reference only; no license was found

Derivative configuration must preserve applicable license and attribution requirements. Unlicensed work is not copied verbatim.

## Positive attributes

- Minimal through coherence and reduction, not emptiness
- Complete and deliberate iconography
- Strong proportions and hierarchy
- Natural or floral photography
- Dark, flat surfaces with one wallpaper-derived accent
- Personality expressed subtly rather than through fandom imagery
- Small, useful widgets that remain visually quiet
- Both a misty/dark mode and a floral/soft mode are plausible

## Avoid

- Developer-dashboard aesthetics: prominent system monitors, dense terminal grids, or persistent technical data
- Overt anime, idol, fandom, cyberpunk, or city imagery
- Generic theme-pack appearance
- Windows/macOS imitation and conspicuous retro nostalgia
- Excessive glass, blur, pills, gradients, and ornamental animation
- Mechanical geometry or arbitrary proportions
- Inconsistent icon weights or excessive Nerd Font glyphs
- Minimalism with no identifying detail

## Initial implementation direction

- NixOS with flakes and Home Manager
- Hyprland on Wayland
- A small custom Waybar rather than copying tPanel wholesale
- Foot or Kitty terminal, pending typography tests
- Rofi-Wayland launcher
- SwayNC notifications
- Fcitx5 Hangul input
- Explicit curated palettes rather than an unreviewed generic theme
- Wallpaper and palette assets tracked in Git
- Restrained rounded corners; minimal blur and animation
- No desktop system monitor or fetch output except when explicitly launched

## Reference survey results

The strongest selections were:

1. 0xTux Desktop
2. ComplexPlatform Flowers

Repeated criticisms focused on genericness, mechanical construction, weak icon completion, poor proportions, and conspicuous geek/fandom signals. Therefore implementation quality and proportion matter more than the nominal color scheme or the number of visible elements.
