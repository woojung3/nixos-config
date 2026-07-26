# Arch-to-NixOS migration decisions

Recorded decisions prevent legacy packages from being carried over merely
because they happen to exist on the Arch installation.

## Keep

- Neovim workflows (`gd`, `K`, completion with Tab, formatting, file tree),
  modernized from vim-plug/CoC to Lua, native LSP and Nix-managed plugins
- Zsh without Oh My Zsh or Powerlevel10k
- `vim`, `vi`, and recursive `sudo` aliases
- `RM_STAR_SILENT`
- Chrome, Obsidian, Thunar, SMPlayer, tmux and Baobab
- English UI, Asia/Seoul timezone, Korean 104-key keyboard and Hangul key
- Wi-Fi, audio and Bluetooth laptop support

## Replace

- XFCE/X11 with Hyprland/Wayland
- IBus Hangul with Fcitx5 Hangul
- PulseAudio with PipeWire's PulseAudio compatibility service
- Language managers as a default workflow with project-specific Nix devShells
- Global F2–F5 shortcuts with mnemonic Super shortcuts to preserve native app
  behavior
- Disabled trash permissions with a normal freedesktop trash; `Shift+Delete`
  remains available for permanent deletion

## Remove

- Chicago95 and XFCE configuration
- Oh My Zsh and Powerlevel10k
- VS Code
- scrcpy and Android platform tools
- torrent software
- ZeroTier
- printer services, KDE Connect and ani-cli
- SDKMAN/pyenv state from the old home directory; add project devShells when
  each checked-out project needs them

No existing home-directory state is migrated automatically. Obsidian notes and
workspaces are restored from their own Git repositories after installation.
