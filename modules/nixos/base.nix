{ pkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    # Keep routine kernel, initrd, udev, and systemd status messages off-screen.
    # Errors and unusually slow services remain visible.
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "systemd.show_status=auto"
      "rd.systemd.show_status=auto"
    ];
    tmp.cleanOnBoot = true;
  };

  networking = {
    networkmanager.enable = true;
    firewall.trustedInterfaces = [ "tailscale0" ];
  };

  time.timeZone = "Asia/Seoul";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ko_KR.UTF-8";
      LC_IDENTIFICATION = "ko_KR.UTF-8";
      LC_MEASUREMENT = "ko_KR.UTF-8";
      LC_MONETARY = "ko_KR.UTF-8";
      LC_NAME = "ko_KR.UTF-8";
      LC_NUMERIC = "ko_KR.UTF-8";
      LC_PAPER = "ko_KR.UTF-8";
      LC_TELEPHONE = "ko_KR.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  console.keyMap = "us";

  users = {
    mutableUsers = true;
    users.jwlee = {
      isNormalUser = true;
      description = "Jinwoo Lee";
      extraGroups = [
        "audio"
        "networkmanager"
        "video"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };

  programs.zsh.enable = true;
  programs.nh = {
    enable = true;
    flake = "/home/jwlee/Workspace/nixos-config";
  };

  security.sudo.wheelNeedsPassword = true;
  services.fwupd.enable = true;
  services.openssh.enable = false;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    extraSetFlags = [ "--accept-routes=true" ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    file
    pciutils
    usbutils
  ];
}
