# Applications and environment

## Desktop

- Hyprland/Wayland, launched through UWSM.
- SDDM with Qylock for login; Hyprlock and Hypridle for session locking/idling.
- Waybar, Bloom Quickshell panels, Rofi and SwayNC.
- PipeWire with PulseAudio compatibility, NetworkManager and Bluetooth support.
- Fcitx5 Hangul, English UI, `Asia/Seoul` timezone and Korean 104-key layout.
- Foot terminal; Chrome, Obsidian, Thunar, Mousepad, SMPlayer, mpv and Baobab.

## Shell and development

- Zsh without Oh My Zsh or Powerlevel10k; tmux for terminal sessions.
- Nix-managed Neovim with native LSP, completion, formatting and a file tree.
- `vim`, `vi` and recursive `sudo` aliases; `RM_STAR_SILENT` for Zsh.
- Basic build tools are installed centrally. Project-specific runtimes and
  toolchains belong in project devShells.
- Super-based desktop shortcuts leave application function keys available.

## User data

User notes, credentials and personal state are not provisioned from this
repository. Restore Obsidian notes/workspaces from their own repositories and
private wallpapers from backup as described in [INSTALL.md](INSTALL.md).

The desktop uses the normal freedesktop trash. `Shift+Delete` remains available
for permanent deletion in applications that support it.

## Configuration ownership

- `modules/nixos/`: system services, packages, hardware and locale.
- `home/jwlee/`: user applications, desktop behavior and Home Manager modules.
- `themes/bloom.nix`: shared palette and fonts.
- `hosts/jwlaptop/`: machine-specific configuration and Disko layout.

Edit the repository and apply it through NixOS/Home Manager. Generated files in
`~/.config` are deployment outputs, not a second source of configuration.
