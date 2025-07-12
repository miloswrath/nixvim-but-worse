{ pkgs, config, lib, ... }:

let
  copilotChat = pkgs.vimPlugins.CopilotChat-nvim;
in {
  # make sure the runtime deps are in your $PATH
  extraPackages = with pkgs; [
    nodejs
    copilot-language-server
    # if you want accurate token‐counting also install tiktoken_core:
    # tiktoken_core
  ];

  plugins.copilot-chat = {
    enable   = true;                 # turn the plugin on
    autoLoad = true;                # only load when you actually call :CopilotChat*
    package  = copilotChat;          # use the Nixpkgs derivation

    # anything under `settings` gets passed straight to `require("CopilotChat").setup(opts)`
    settings = {
      copilot_node_command = lib.getExe pkgs.nodejs;
      lsp_binary = lib.getExe pkgs.copilot-language-server;
      # floating window centred in the editor
      window = {
        layout   = "float";
        relative = "editor";
        width    = 0.6;    # 60% of the editor width
        height   = 0.5;    # 50% of the editor height
        row      = 1;    # centred vertically
        col      = 2;    # centred horizontally
      };

      keymaps = {
        open     = "<leader>cc";
        explain  = "<leader>ce";
        optimize = "<leader>co";
      };
    };

  };
}

