# Installation runbook

This runbook is intentionally divided into a safe phase and a destructive
phase. The destructive phase must not begin until the repository has been
pushed to GitHub, the flake has passed validation, and the disk owner has given
final approval immediately before formatting.

## Gate 1 — safe preparation

- [ ] The latest commit is visible at <https://github.com/woojung3/nixos-config>.
- [ ] GitHub Actions passes for that commit.
- [ ] `nix flake check` passes locally or in CI.
- [ ] The repository contains no credentials or private data.
- [ ] A NixOS 26.05 installer USB boots successfully.
- [ ] The installer has network access.
- [ ] `lsblk` confirms the intended SSD is still `/dev/sda`, model
      `KINGSTON RBUSNS8180DS3128GJ`, approximately 119 GiB.

From the installer environment:

```bash
sudo -i
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git nixpkgs#disko
cd /tmp
git clone https://github.com/woojung3/nixos-config.git
cd nixos-config
nix --extra-experimental-features "nix-command flakes" flake check
lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
```

Stop here. The commands above do not format the SSD.

## Gate 2 — destructive confirmation

> **DANGER: the next Disko command irreversibly erases every partition and all
> data on `/dev/sda`.**

Immediately before continuing:

- [ ] Read the current `lsblk` output aloud or inspect it carefully.
- [ ] Confirm `/dev/sda` is the 119 GiB Kingston internal SSD.
- [ ] Confirm there is no external disk accidentally using that path.
- [ ] Obtain explicit final approval to erase the disk.

Only after all four checks:

```bash
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko ./hosts/jwlaptop/disk.nix
```

## Install NixOS

Disko mounts the new filesystems below `/mnt`.

```bash
nixos-install --flake .#jwlaptop
nixos-enter --root /mnt -c 'passwd jwlee'
```

Set a unique user password. `nixos-install` may also request a root password.
No password or hash belongs in this public repository.

Before rebooting:

```bash
findmnt /mnt
nixos-enter --root /mnt -c 'systemctl --no-pager status display-manager.service' || true
sync
```

Then reboot:

```bash
reboot
```

Remove the installer USB when firmware begins booting. Log in as `jwlee`, open
a terminal, and restore the configuration checkout:

```bash
mkdir -p ~/Workspace
cd ~/Workspace
git clone https://github.com/woojung3/nixos-config.git
cd nixos-config
nh os switch
```

## First-boot verification

- [ ] Hyprland starts from greetd.
- [ ] Wi-Fi connects through NetworkManager.
- [ ] The physical Hangul key switches Korean input.
- [ ] Audio output and microphone work.
- [ ] Brightness and volume keys work.
- [ ] Suspend and resume work with the lid.
- [ ] Bluetooth detects nearby devices.
- [ ] Chrome, Obsidian, Thunar, SMPlayer and Neovim launch.
- [ ] `Super+T`, `Super+B`, `Super+E`, `Super+Space` and workspaces work.
- [ ] The normal desktop trash works; `Shift+Delete` performs permanent deletion.
