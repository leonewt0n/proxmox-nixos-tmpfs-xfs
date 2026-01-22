{
  description = "NixOS Hypervisor with Proxmox VE and Impermanence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # The module that lets you run Proxmox VE on NixOS
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    
    # The module for ephemeral root
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, proxmox-nixos, impermanence, ... }@inputs: {
    nixosConfigurations."hypervisor" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Import the modules
        proxmox-nixos.nixosModules.proxmox-ve
        impermanence.nixosModules.impermanence
        ./configuration.nix
      ];
    };
  };
}
