{ pkgs, ... }:
let
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/6d14586a5917a1ec7f045ac97e6d00c68ea5d9f3.tar.gz");
in
{
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ rust-overlay ];

  home.packages = with pkgs; [
    fastfetch
    gh
    claude-code

    # Programming languages & tools
    ## JS / TS
    nodejs
    pnpm
    ## C/C++
    clang
    ninja
    cmake
    ## Others
    go
    python3
    rust-bin.nightly.latest.default
    ## Language servers
    clang-tools
    lua-language-server
    pyright
    nodePackages.typescript-language-server
    gopls
    rust-analyzer
    nil
    ## Formatters
    stylua
    black
    nodePackages.prettier
    nixpkgs-fmt
    ## Linters
    nodePackages.eslint
    ruff
    golangci-lint
    shellcheck
    markdownlint-cli
    ## Debug adapters
    python3Packages.debugpy
    delve
    lldb
    vscode-js-debug
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "alanpeabody";
      plugins = [
        "git"
        "sudo"
        "docker"
        "docker-compose"
        "kubectl"
      ];
    };

    shellAliases = {
      e = "exit";
      c = "clear";

      gp = "git push";
      gpf = "git push -f";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "pkulik0";
        email = "me@pkulik.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      -- Leader	
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Indentation settings
      vim.opt.expandtab = true       -- Use spaces instead of tabs
      vim.opt.shiftwidth = 2         -- Number of spaces for each indentation level
      vim.opt.tabstop = 2            -- Number of spaces a tab counts for
      vim.opt.softtabstop = 2        -- Number of spaces for tab key in insert mode
      vim.opt.smartindent = true     -- Smart autoindenting on new lines

      -- Line numbers
      vim.opt.number = true          -- Show absolute line number on current line
      vim.opt.relativenumber = true  -- Show relative line numbers
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup {
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            },
          }
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require('which-key').setup {}
        '';
      }
      nvim-web-devicons
      plenary-nvim
      nui-nvim
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup {
            options = {
              theme = 'auto',
              component_separators = { left = "", right = ""},
              section_separators = { left = "", right = ""},
            },
          }
        '';
      }
      {
        plugin = neo-tree-nvim;
        type = "lua";
        config = ''
          require('neo-tree').setup {}
          vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true })
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local capabilities = require('blink.cmp').get_lsp_capabilities()

          -- Configure LSPs using vim.lsp.config nvim 0.11+
          local servers = {'lua_ls', 'pyright', 'ts_ls', 'gopls', 'rust_analyzer', 'clangd', 'nil_ls'}
          for _, server in ipairs(servers) do
            vim.lsp.config[server] = { capabilities = capabilities }
          end
          vim.lsp.enable(servers)

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })

          vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostics' })
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
          vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
        '';
      }
      {
        plugin = blink-cmp;
        type = "lua";
        config = ''
          require('blink-cmp').setup {
            completion = {
              accept = {
                auto_brackets = {
                  enabled = true
                }
              }
            }
          }
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          require('telescope').setup {}
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
          vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
        '';
      }
      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
          require('conform').setup {
            formatters_by_ft = {
              lua = { "stylua" },
              python = { "black" },
              javascript = { "prettier" },
              typescript = { "prettier" },
              go = { "gofmt" },
              rust = { "rustfmt" },
              nix = { "nixpkgs_fmt" },
            },
          }
          vim.keymap.set('n', '<leader>cf', function()
            require('conform').format({ async = true, lsp_fallback = true })
          end, { desc = 'Format buffer' })
        '';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup {}
        '';
      }
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require('Comment').setup {}
        '';
      }
      {
        plugin = nvim-lint;
        type = "lua";
        config = ''
          local lint = require('lint')

          lint.linters_by_ft = {
            javascript = { 'eslint' },
            typescript = { 'eslint' },
            python = { 'ruff' },
            go = { 'golangcilint' },
            sh = { 'shellcheck' },
            markdown = { 'markdownlint' },
          }

          -- Auto-lint on save and text change
          vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
            callback = function()
              lint.try_lint()
            end,
          })
        '';
      }
      {
        plugin = nvim-dap;
        type = "lua";
        config = ''
          local dap = require('dap')

          -- Python
          dap.adapters.python = {
            type = 'executable',
            command = '${pkgs.python3Packages.debugpy}/bin/python',
            args = { '-m', 'debugpy.adapter' },
          }
          dap.configurations.python = {
            {
              type = 'python',
              request = 'launch',
              name = 'Launch file',
              program = "''${file}",
              pythonPath = '${pkgs.python3}/bin/python',
            },
          }

          -- Go
          dap.adapters.go = {
            type = 'server',
            port = "''${port}",
            executable = {
              command = '${pkgs.delve}/bin/dlv',
              args = { 'dap', '-l', '127.0.0.1:''${port}' },
            },
          }
          dap.configurations.go = {
            {
              type = 'go',
              name = 'Debug',
              request = 'launch',
              program = "''${file}",
            },
            {
              type = 'go',
              name = 'Debug Package',
              request = 'launch',
              program = "''${fileDirname}",
            },
            {
              type = 'go',
              name = 'Debug test',
              request = 'launch',
              mode = 'test',
              program = "''${file}",
            },
          }

          -- JavaScript/TypeScript
          dap.adapters['pwa-node'] = {
            type = 'server',
            host = 'localhost',
            port = "''${port}",
            executable = {
              command = '${pkgs.vscode-js-debug}/bin/js-debug',
              args = { "''${port}" },
            },
          }
          dap.configurations.javascript = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch file',
              program = "''${file}",
              cwd = "''${workspaceFolder}",
            },
          }
          dap.configurations.typescript = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch file',
              program = "''${file}",
              cwd = "''${workspaceFolder}",
              runtimeExecutable = '${pkgs.nodejs}/bin/node',
              runtimeArgs = { '-r', 'ts-node/register' },
            },
          }

          -- C/C++/Rust
          dap.adapters.lldb = {
            type = 'executable',
            command = '${pkgs.lldb}/bin/lldb-dap',
            name = 'lldb',
          }
          dap.configurations.c = {
            {
              name = 'Launch',
              type = 'lldb',
              request = 'launch',
              program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
              end,
              cwd = "''${workspaceFolder}",
              stopOnEntry = false,
              args = {},
            },
          }
          dap.configurations.cpp = dap.configurations.c
          dap.configurations.rust = dap.configurations.c

          -- Keybindings
          vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
          vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
          vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
          vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
          vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
          vim.keymap.set('n', '<leader>B', function()
            dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
          end, { desc = 'Debug: Set Conditional Breakpoint' })
        '';
      }
      {
        plugin = nvim-dap-ui;
        type = "lua";
        config = ''
          local dap, dapui = require('dap'), require('dapui')

          dapui.setup {}

          -- Auto-open UI when debugging starts
          dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close()
          end

          -- Toggle UI manually
          vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
        '';
      }
      {
        plugin = github-nvim-theme;
        type = "lua";
        config = ''
          require('github-theme').setup {}
          vim.cmd('colorscheme github_dark_default')
        '';
      }
    ];
  };
}
