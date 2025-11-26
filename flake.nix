{
  description = "Zak's neovim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, nixvim, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { system, ... }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;

          overlays = [
            (_final: prev: {
              stable = import inputs.nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
                config.nvidia.acceptLicense = true;
            };
	   })
          ];
        };

        # Force nixvim to use OUR pkgs and OUR vimPlugins
        nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
          inherit pkgs;
          module = import ./config;

          extraSpecialArgs = {
            inherit pkgs;
          };
        };
      in {
        packages.default = nvim;
      };
    };
}
