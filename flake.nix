{
  description = "Harvey's neovim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      nixpkgs-stable,
      nixvim,
      flake-parts,
      ...
    } @ inputs:
      flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        perSystem = { pkgs, system, ... }: let
          nixvimLib = nixvim.lib.${system};
          nixvim' = nixvim.legacyPackages.${system};
          nixvimModule = {
            inherit pkgs;
            module = import ./config; # import the module directly
            # You can use `extraSpecialArgs` to pass additional arguments to your module files
            extraSpecialArgs = {
              # inherit (inputs) foo;

              # this is the key bit:
              extraConfig = ''
                -- bootstrap copilot.lua on startup so :Copilot works
                -- you can pass any plugin-specific opts here too:
                require("copilot").setup({
                  suggestion = { auto_trigger = true, debounce = 75 },
                  panel      = { enabled = false,  auto_refresh = true },
                  no_tab_map = true,
                  keymaps = {
                    accept = "<C-l>",
                  },
                })
              '';
            };
          };
          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in {
          checks = {
            # Run `nix flake check .` to verify that your config is not broken
            default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
          };

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (_final: _prev: {
                stable = import inputs.nixpkgs-stable {
                  inherit system;
                  config.allowUnfree = true;
                  config.nvidia.acceptLicense = true;
                };
              })

              # Fixed lualine-nvim overlay
              (final: prev: {
                vimPlugins = prev.vimPlugins // {
                  lualine-nvim = prev.vimPlugins.lualine-nvim.overrideAttrs {
                    version = "unstable-2025-11-01";
                    src = prev.fetchFromGitHub {
                      owner = "nvim-lualine";
                      repo = "lualine.nvim";
                      rev = "e58d8d116f2f2c3b6c8e9c9f8f8e8d7c6b5a493c";
                      hash = "sha256-X3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3g=";
                    };
                  };
                };
              })
            ];
            config = { allowUnfree = true; };
          };

          # Lets you run `nix run .` to start nixvim
          packages.default = nvim;
        };
      };
}
