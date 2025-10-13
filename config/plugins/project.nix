{
  plugins = {
    project-nvim = {
      enable = true;
      enableTelescope = false;
      settings = {
        telescope.enabled = false;
        detection_methods = [
          "lsp"
          "pattern"
        ];
        exclude_dirs = [
          "~/.local/*"
          "~/.cache/*"
          "~/.cargo/*"
          "~/.node_modules/*"
          "~/.pnpm-store/*"
          "~/.local/share/pnpm/*"
        ];
        patterns = [
          "flake.nix"
          "flake.lock"
          "LICENSE"
          "README.md"
          "CMakeLists.txt"
          "Makefile"
          "meson.build"
          "PKGBUILD"
          "Cargo.toml"
          "package.json"
          "composer.json"
          "lazy-lock.json"
          "!>home"
          "!=tmp"
          ".git"
          "*.sln"
          ".vs"
          ".vscode"
          ".hg"
          ".bzr"
          ".svn"
          "_darcs"
        ];
      };
    };
  };

  extraConfigLua = ''
    vim.schedule(function()
      local project_loaded = pcall(require, 'project')
      if not project_loaded or vim.g.project_setup ~= 1 then
        return
      end

      local ok, telescope = pcall(require, 'telescope')
      if ok and telescope then
        pcall(telescope.load_extension, 'projects')
      end
    end)
  '';
}
