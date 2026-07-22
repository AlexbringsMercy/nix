{
  description = "Alex's T2 MacBook NixOS + Hyprland configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";

    nixos-hardware.url = "github:NixOS/nixos-hardware/fccfa9031a85b78a437f2f153c1f6449f3bc3185";

    t2fanrd = {
      url = "github:GnomedDev/T2FanRD";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/165228b0efefc3e635e5174020c40ea64271dc25";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aurora-shell = {
      url = "path:./modules/home/aurora-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      hyprlandOverlay = _: prev: { # Aurora: carry the approved tiled-drag grab-anchor fix in every package set.
        hyprland = prev.hyprland.overrideAttrs (old: { # Aurora: extend nixpkgs' pinned Hyprland derivation without replacing its attributes.
          patches = (old.patches or [ ]) ++ [ # Aurora: retain any nixpkgs patches before applying the local compositor fix.
            ./modules/nixos/patches/hyprland-drag-anchor.patch # Aurora: preserve the normalized grab anchor when a tiled window floats on pickup.
          ]; # Aurora: finish the additive Hyprland patch list.
        }); # Aurora: finish the patched Hyprland derivation.
      }; # Aurora: share one compositor override across standalone Home Manager and NixOS evaluation.

      homePkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ hyprlandOverlay ]; # Aurora: make standalone pkgs.hyprland and hyprlandPlugins consume the same patched compositor.
      };

      mkMacbook =
        {
          firmwareSource ? null,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs firmwareSource;
          };
          modules = [
            {
              nixpkgs.overlays = [ hyprlandOverlay ]; # Aurora: make the integrated NixOS and Home Manager package set use the patched compositor.
            }
            nixos-hardware.nixosModules.apple-t2
            inputs.t2fanrd.nixosModules.t2fanrd
            home-manager.nixosModules.home-manager
            ./hosts/macbook
          ];
        };
    in
    {
      lib.mkMacbook = mkMacbook;

      # Evaluates everywhere. The machine-local adapter supplies proprietary
      # firmware for the configuration that is actually installed.
      nixosConfigurations.macbook = mkMacbook { };

      homeConfigurations.alex = home-manager.lib.homeManagerConfiguration {
        # Keep the standalone evaluator aligned with modules/nixos/base.nix.
        # Chrome is part of the permanent desktop and otherwise makes
        # `nix flake check` fail before the integrated NixOS graph is reached.
        pkgs = homePkgs;
        modules = [ inputs.aurora-shell.homeManagerModules.default ./home/alex ]; # Aurora: keep standalone Home Manager evaluation aware of the shell options.
      };

      packages.${system} = {
        home-activation = self.homeConfigurations.alex.activationPackage;
        aurora-shell = inputs.aurora-shell.packages.${system}.caelestia-shell;
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
