{pkgs, ...}: {
  plugins = {
    treesitter-context = {enable = false;};
    treesitter = {
      enable = true;
      package = pkgs.vimPlugins.nvim-treesitter;
      nixvimInjections = true;
      nixGrammars = true;
      folding.enable = false;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        nix
        bash
        cmake
        make
        python
        rust
        c
        cpp
        regex
        gitcommit
        gitignore
        markdown
        markdown_inline
        json
        lua
        toml
        yaml
        zig
        eex
        heex
      ];
      settings = {
        incremental_selection.enable = true;
        indent.enable = true;
        highlight.enable = true;
      };
    };
  };
}
