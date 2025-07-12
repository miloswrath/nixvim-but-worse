{ pkgs, lib, config, ... }:  # <-- make sure pkgs is here
{
  plugins = {
    luasnip.enable = true;
    cmp-nvim-lsp = {enable = true;}; # lsp
    cmp-nvim-lua = {enable = true;};
    cmp-buffer = {enable = true;};
    cmp-path = {enable = true;};
    cmp_luasnip = {enable = true;};
    cmp-cmdline = {enable = false;};
    nix.enable = true;
    # existing plugins...
    copilot-lua = {
      enable = true;
      package = pkgs.vimPlugins.copilot-lua;
      autoLoad = false;
      settings = {
        suggestion = { enabled = true; }; # disable floating suggestions if using cmp
        panel = { enabled = false; };      # disable Copilot panel
      };
    };

    copilot-cmp = {
      enable = true;
      package = pkgs.vimPlugins.copilot-cmp;
    };

    # your existing cmp settings, now with copilot-cmp included
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        snippet = {
          expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        };
        experimental = {
          ghost_text = true;
        };
        performance = {
          debounce = 60;
          fetchingTimeout = 200;
          maxViewEntries = 30;
        };
        formatting = {
          fields = ["kind" "abbr" "menu"];
        };
        window = {
          completion = {
            border = "rounded";
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
          };
          documentation = {
            border = "rounded";
          };
        };
        sources = [
          { name = "copilot"; } # <-- ✅ add copilot source here
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
          { name = "nvim_lua"; }
          { name = "path"; }
          { name = "crates"; }
        ];
        mapping = {
          "<Tab>" = "cmp.mapping.confirm({ select = true })";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-j>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })";
          "<C-k>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })";
          "<C-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })";
          "<C-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })";
          "<C-e>" = "cmp.mapping.close()";
        };
      };
    };
  };
}

