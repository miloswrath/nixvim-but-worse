{pkgs, ...}: let
  servers = [
    {
      name = "rust_analyzer";
      config = {
        settings = {
          "rust-analyzer" = {
            diagnostics.enable = true;
          };
        };
      };
    }
    {name = "lua_ls";}
    {name = "yamlls";}
    {name = "nil_ls";}
    {name = "marksman";}
    {name = "erlangls";}
    {
      name = "elixirls";
      config.cmd = ["elixir-ls"];
    }
    {name = "pyright";}
    {name = "bashls";}
    {name = "clangd";}
    {name = "cmake";}
    {name = "csharp_ls";}
    {name = "gopls";}
    {name = "jsonls";}
    {
      name = "ts_ls";
      config.filetypes = [
        "javascript"
        "javascriptreact"
        "javascript.jsx"
        "typescript"
        "typescriptreact"
        "typescript.tsx"
      ];
    }
  ];
  serversJson = builtins.toJSON servers;
in {
  plugins = {
    nix.enable = true;
    crates.enable = true;
    lsp = {
      enable = true;
      servers = {
        rust_analyzer = {
          enable = true;
          settings = {
            diagnostics.enable = true;
            # completion.postfix.enable = false; # Disable snippet suggestions because we have no snippet engine at the moment.
          };
          installCargo = true;
          installRustc = true;
        };
        # gdscript.enable = true;
        lua_ls.enable = true;
        yamlls.enable = true;
        nil_ls.enable = true;
        marksman.enable = true;
        # pylsp.enable = true;
        pyright.enable = true;
        bashls.enable = true;
        #ccls.enable = true;
        clangd.enable = true;
        cmake.enable = true;
        csharp_ls.enable = true;
        gopls.enable = true;
        jsonls.enable = true;
        ts_ls.enable = true;
        # html.enable = true;
        # volar.enable = true;
        # terraformls = {enable = true;};
        # ansiblels.enable = true;
      };
      keymaps = {
        silent = true;
        diagnostic = {
          "<leader>k" = "goto_prev";
          "<leader>j" = "goto_next";
        };
        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "gi" = "implementation";
          "gr" = "references";
          "gt" = "type_definition";
          "K" = "hover";

          "<C-k>" = "signature_help";

          "<leader>ca" = "code_action";
          "<leader>rn" = "rename";
          "<leader>wa" = "add_workspace_folder";
          "<leader>wr" = "remove_workspace_folder";
        };
      };
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-lspconfig
  ];

  extraPackages = with pkgs; [
    rust-analyzer
    lua-language-server
    yaml-language-server
    nil
    erlang-ls
    elixir-ls
    pyright
    nodePackages.typescript
    bash-language-server
    clang-tools
    cmake-language-server
    csharp-ls
    gopls
    vscode-langservers-extracted
    nodePackages.typescript-language-server
  ];

  extraConfigLuaPre = ''
    local function decode_json(payload)
      local ok, result = pcall(vim.json.decode, payload)
      if ok then
        return result
      end
      return vim.fn.json_decode(payload)
    end

    local server_specs = decode_json([==[${serversJson}]==])

    local has_new_api = type(vim.lsp) == 'table' and vim.lsp.config and vim.lsp.enable
    local legacy_ok, legacy = pcall(require, 'lspconfig')

    local base_capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    if cmp_ok then
      base_capabilities = vim.tbl_deep_extend('force', base_capabilities, cmp_lsp.default_capabilities())
    end
    base_capabilities.textDocument = base_capabilities.textDocument or {}
    base_capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    local function merge_capabilities(config)
      local opts = vim.tbl_deep_extend('force', {}, config or {})
      local existing_capabilities = opts.capabilities or {}
      opts.capabilities = vim.tbl_deep_extend('force', vim.deepcopy(base_capabilities), existing_capabilities)
      return opts
    end

    for _, spec in ipairs(server_specs) do
      local name = spec.name
      local config = merge_capabilities(spec.config)

      if has_new_api then
        vim.lsp.config(name, config)
        if config.enable ~= false then
          local ok, err = pcall(vim.lsp.enable, name)
          if not ok then
            vim.schedule(function()
              vim.notify(string.format('[lsp] failed to enable %s: %s', name, err), vim.log.levels.WARN)
            end)
          end
        end
      elseif legacy_ok then
        local ok, server = pcall(function()
          return legacy[name]
        end)
        if ok and type(server) == 'table' and type(server.setup) == 'function' then
          server.setup(config)
        else
          vim.schedule(function()
            vim.notify(string.format('[lsp] legacy configuration for %s is unavailable', name), vim.log.levels.WARN)
          end)
        end
      else
        vim.schedule(function()
          vim.notify(string.format('[lsp] no configuration backend available for %s', name), vim.log.levels.ERROR)
        end)
      end
    end

    local diagnostic_opts = { silent = true }
    vim.keymap.set('n', '<leader>k', vim.diagnostic.goto_prev, vim.tbl_extend('force', diagnostic_opts, { desc = 'Prev diagnostic' }))
    vim.keymap.set('n', '<leader>j', vim.diagnostic.goto_next, vim.tbl_extend('force', diagnostic_opts, { desc = 'Next diagnostic' }))

    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP keymaps',
      callback = function(event)
        local opts = { buffer = event.buf, silent = true }
        local function buf_map(mode, lhs, rhs, desc)
          opts.desc = desc
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        buf_map('n', 'gd', vim.lsp.buf.definition, 'Goto Definition')
        buf_map('n', 'gD', vim.lsp.buf.declaration, 'Goto Declaration')
        buf_map('n', 'gi', vim.lsp.buf.implementation, 'Goto Implementation')
        buf_map('n', 'gr', vim.lsp.buf.references, 'References')
        buf_map('n', 'gt', vim.lsp.buf.type_definition, 'Type Definition')
        buf_map('n', 'K', vim.lsp.buf.hover, 'Hover')
        buf_map('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature Help')
        buf_map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
        buf_map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
        buf_map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add Workspace Folder')
        buf_map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove Workspace Folder')
      end,
    })
  '';
}
