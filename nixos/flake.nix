# flake.nix

{
  description = "I love anime girls";

  inputs = {
    # Nixos unstable branch (default)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Secure Boot
		lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
			inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, ... }: {
    nixosConfigurations = {
		T480 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
				./hardware-configuration.nix
				./throttled.nix
				./neovim.nix

				# Secure boot
				 lanzaboote.nixosModules.lanzaboote

          ({ pkgs, lib, ... }: {

          environment.systemPackages = [
          # For debugging and troubleshooting Secure Boot.
            pkgs.sbctl
          ];

          # Lanzaboote currently replaces the systemd-boot module.
          # This setting is usually set to true in configuration.nix
          # generated at installation time. So we force it to false
          # for now.
          boot.loader.systemd-boot.enable = lib.mkForce false;

          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
          };
        })
      ];
    };
  };
};
}
