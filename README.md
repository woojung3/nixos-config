# jwlaptop NixOS configuration

Declarative NixOS and Home Manager configuration for an Acer Aspire A515-52.

> This repository contains a destructive Disko layout for `/dev/sda`. Merely
> cloning, evaluating, or building the flake does not alter disks. Do not run
> Disko until the installation checklist in [`INSTALL.md`](INSTALL.md) has been
> reviewed and the target disk has been confirmed.

## System

- NixOS 26.05
- Hyprland on Wayland, launched through UWSM
- SDDM with the Qylock `pixel-munchlax` login theme
- Workspace-aware wallpapers through awww
- Home Manager
- Unencrypted Btrfs with zstd compression
- systemd-boot
- PipeWire, NetworkManager, Bluetooth and Fcitx5 Hangul
- Bloom visual theme derived from the selected Flowers reference

## Apply

After installation and cloning this repository to
`~/Workspace/nixos-config`:

```bash
nh os switch
```

Inspect the result before removing old generations. NixOS boot generations
remain available from the boot menu if a system change fails.

## Key bindings

| Binding | Action |
|---|---|
| `Super+T` | Terminal |
| `Super+B` | Browser |
| `Super+E` | File manager |
| `Super+N` | Mousepad text editor |
| `Super+Space` | Application launcher |
| `Super+Q` / `Alt+F4` | Close window |
| `Super+L` | Lock |
| `Super+Escape` | Power menu |
| `Super+1..9` | Switch workspace |
| `Super+Shift+1..9` | Move window to workspace |
| `Super+arrows` | Move focus |
| `Super+Shift+arrows` | Move window |
| `Alt+Tab` / `Alt+Shift+Tab` | Cycle windows forward / backward |
| `Super+Shift+S` | Region screenshot |

The Korean 104-key layout is configured so the physical Hangul key switches
Fcitx5 input methods. `Ctrl+Space` is retained as a fallback.

## Design

The desktop aims to be quiet and minimal without becoming generic. It uses a
wallpaper-led palette, restrained motion, complete iconography, and avoids
persistent developer dashboards or conspicuous fandom imagery. See
[`DESIGN.md`](DESIGN.md) and [`CREDITS.md`](CREDITS.md).
