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
- Waybar with Quickshell brightness, power, calendar, battery and sound panels
- Optional CRT effect, toggled by right-clicking the Waybar flower
- Unencrypted Btrfs with zstd compression
- systemd-boot
- PipeWire, NetworkManager, Bluetooth and Fcitx5 Hangul
- Bloom visual theme with a Flowers-derived palette

## Apply

After installation and cloning this repository to
`~/Workspace/nixos-config`:

```bash
nh os switch
```

Add new files to Git before using the Git-backed flake; untracked files are not
included. To apply the working directory explicitly, including untracked files:

```bash
sudo nixos-rebuild switch --flake "path:$PWD#jwlaptop"
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
| `Super+1..9`, `Super+0` | Switch to workspace 1–9, 10 |
| `Super+Shift+1..9`, `Super+Shift+0` | Move window to workspace 1–9, 10 |
| `Super+arrows` | Move focus |
| `Super+Shift+arrows` | Move window |
| `Alt+Tab` / `Alt+Shift+Tab` | Cycle windows forward / backward |
| `Super+Shift+S` | Region screenshot |

The Korean 104-key layout is configured so the physical Hangul key switches
Fcitx5 input methods. `Ctrl+Space` is retained as a fallback.

## Desktop controls

| Waybar item | Action |
|---|---|
| Flower, left-click | Application launcher |
| Flower, right-click | CRT effect on/off |
| Volume | System volume, output selection and MPRIS media controls |
| Volume, right-click | pavucontrol |
| Brightness | Brightness slider, with a 5% lower bound |
| Battery | Charge information and power profiles |
| Clock | Calendar |
| Power | Session and power actions |

Panels close on Escape, outside click or the same Waybar button. Brightness and
volume do not change on hover-wheel input. The bar is 34px high; workspace
labels use Chinese numerals without changing workspace IDs.

## Validation

From the repository root:

```bash
nix flake check "path:$PWD" --print-build-logs
nix build --no-link "path:$PWD#nixosConfigurations.jwlaptop.config.system.build.toplevel"
```

Flake checks run the logic/helper suites, CRT shader validation and offscreen Qt
UI regression tests. CI runs the same checks. Test dependencies are supplied by
Nix; the checks do not change real hardware, applications or the compositor.
See [tests/README.md](tests/README.md) for focused runs and live-check boundaries.

## Documentation

- [Installation and disk safety](INSTALL.md)
- [Applications and environment](ENVIRONMENT.md)
- [Design and interaction rules](DESIGN.md)
- [Panel architecture and maintenance](home/jwlee/quickshell/README.md)
- [CRT configuration, performance and limitations](home/jwlee/crt/README.md)
- [Credits and provenance](CREDITS.md)
