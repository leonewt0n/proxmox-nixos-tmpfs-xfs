{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.proxmox-nixos.nixosModules.proxmox-ve
  ];

  # --- 1. XFS Configuration ---
  # Ensure XFS support is available in the kernel/initrd
  boot.supportedFilesystems = [ "xfs" ];

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/persist"; # Ensure your partition label matches
    fsType = "xfs";
    neededForBoot = true;
  };

  # --- 2. Auto-Update & Reboot Strategy ---
  system.autoUpgrade = {
    enable = true;
    
    # Check for updates daily
    dates = "daily";
    randomizedDelaySec = "45min"; # Jitters the update time to avoid thundering herd
    
    # Point this to your flake's origin (e.g., GitHub or local path)
    # If using a local path, ensure the git user has permissions
    flake = "github:yourusername/your-repo"; 
    
    # Arguments to pass to nixos-rebuild
    flags = [ 
      "--update-input" "nixpkgs" # Explicitly update the nixpkgs input
      "--commit-lock-file"       # (Optional) Commit the lock file changes if using a local repo
      "-L"                       # Print build logs
    ];

    # CRITICAL for Impermanence:
    # "boot" builds the config and sets it as default for the NEXT boot.
    # It does NOT try to live-patch your running RAM-disk system (which "switch" does).
    operation = "boot"; 
    
    # Trigger a reboot if the build succeeds and changes were detected
    allowReboot = true; 
  };

  # --- Impermanence & Proxmox (Existing Context) ---
  
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/pve-cluster"
      "/var/lib/vz"
      "/etc/ssh"
      # ... add other directories as needed
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # Standard Ephemeral Root
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
}
