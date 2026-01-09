{ pkgs, config, ... }:
{
  home.packages = with pkgs.unstable; [
    # Language servers
    clang-tools
    lua-language-server
    pyright
    gopls
    nil
    zls
    cmake-language-server
    # Formatters
    stylua
    black
    nodePackages.prettier
    nixfmt
    gofumpt
    cmake-format
    golines
    gomodifytags
    gotests
    impl
    iferr
    # Linters
    nodePackages.eslint
    ruff
    golangci-lint
    shellcheck
    markdownlint-cli
    # Debug adapters
    python3Packages.debugpy
    delve
    lldb
    vscode-js-debug
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraWrapperArgs = [
      "--run"
      "export ANTHROPIC_API_KEY=$(cat ${config.sops.secrets.anthropic_api_key.path} 2>/dev/null || true)"
    ];

    extraLuaConfig = ''
      -- Leader
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Indentation settings
      vim.opt.expandtab = true       
      vim.opt.shiftwidth = 2        
      vim.opt.tabstop = 2          
      vim.opt.softtabstop = 2     
      vim.opt.smartindent = true 

      -- Line numbers
      vim.opt.number = true
      vim.opt.relativenumber = true

      vim.filetype.add({
        extension = {
          ixx = 'cpp',
          cppm = 'cpp',
          ccm = 'cpp',
        }
      })
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
          vim.keymap.set('n', '<leader>o', ':Neotree focus<CR>', { silent = true })
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local capabilities = require('blink.cmp').get_lsp_capabilities()

          -- Configure LSPs using vim.lsp.config nvim 0.11+
          local servers = {'lua_ls', 'pyright', 'gopls', 'clangd', 'nil_ls', 'zls', 'cmake'}
          for _, server in ipairs(servers) do
            vim.lsp.config[server] = { capabilities = capabilities }
          end

          vim.lsp.config.clangd = {
            capabilities = capabilities,
            cmd = { 'clangd', '--compile-commands-dir=build' },
          }

          vim.lsp.enable(servers)

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature help' })
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
          vim.keymap.set('n', '<leader>ds', vim.lsp.buf.document_symbol, { desc = 'Document symbols' })
          vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, { desc = 'Workspace symbols' })

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
          require('blink-cmp').setup{
            keymap = {
              preset = 'default',
              ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
              ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
              ['<CR>'] = { 'accept', 'fallback' },
              ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
              ['<C-e>'] = { 'hide', 'fallback' },
            },
            sources = {
              default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
              providers = {
                minuet = {
                  name = 'minuet',
                  module = 'minuet.blink',
                  score_offset = 10,  -- Increased to rank higher
                  async = true,
                },
              },
            },
            appearance = {
              use_nvim_cmp_as_default = true,
            },
          }
        '';
      }
      {
        plugin = minuet-ai-nvim;
        type = "lua";
        config = ''
          require('minuet').setup {
            provider = 'claude',
            provider_options = {
              claude = {
                model = 'claude-haiku-4-5',
                max_tokens = 512,
              },
            },
            n_completions = 1,  -- For inline, usually 1 is enough
            throttle = 1000,
            debounce = 500,
            auto_trigger = true,
            notify = 'verbose',
            -- Enable inline ghost text
            virtualtext = {
              auto_trigger_ft = {
                'python', 'lua', 'javascript', 'typescript', 'rust', 'go',
                'c', 'cpp', 'nix', 'sh', 'bash', 'zsh'
              },
              keymap = {
                accept = '<Tab>',  -- Accept suggestion
                accept_line = '<C-l>',  -- Accept one line
              },
            },
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
          vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Find document symbols' })
          vim.keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Find workspace symbols' })
          vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find diagnostics' })
          vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Find references' })
          vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations, { desc = 'Find implementations' })
        '';
      }
      {
        plugin = typescript-tools-nvim;
        type = "lua";
        config = ''
          require('typescript-tools').setup {
            capabilities = require('blink.cmp').get_lsp_capabilities(),
            settings = {
              separate_diagnostic_server = true,
              publish_diagnostic_on = "insert_leave",
              expose_as_code_action = "all",
              tsserver_max_memory = "auto",
              tsserver_locale = "en",
              complete_function_calls = true,
              include_completions_with_insert_text = true,
              code_lens = "off",
              disable_member_code_lens = true,
              jsx_close_tag = {
                enable = true,
                filetypes = { "javascriptreact", "typescriptreact" },
              },
              tsserver_file_preferences = {
                includeInlayParameterNameHints = "all",
                includeCompletionsForModuleExports = true,
                quotePreference = "auto",
              },
              tsserver_format_options = {
                allowIncompleteCompletions = false,
                allowRenameOfImportPath = false,
              },
            },
          }

          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            callback = function()
              vim.keymap.set('n', '<leader>to', ':TSToolsOrganizeImports<CR>', { desc = 'TS: Organize Imports', buffer = true })
              vim.keymap.set('n', '<leader>ts', ':TSToolsSortImports<CR>', { desc = 'TS: Sort Imports', buffer = true })
              vim.keymap.set('n', '<leader>tu', ':TSToolsRemoveUnused<CR>', { desc = 'TS: Remove Unused', buffer = true })
              vim.keymap.set('n', '<leader>ti', ':TSToolsAddMissingImports<CR>', { desc = 'TS: Add Missing Imports', buffer = true })
              vim.keymap.set('n', '<leader>tf', ':TSToolsFixAll<CR>', { desc = 'TS: Fix All', buffer = true })
              vim.keymap.set('n', '<leader>tg', ':TSToolsGoToSourceDefinition<CR>', { desc = 'TS: Go to Source Definition', buffer = true })
              vim.keymap.set('n', '<leader>tr', ':TSToolsRenameFile<CR>', { desc = 'TS: Rename File', buffer = true })
              vim.keymap.set('n', '<leader>tR', ':TSToolsFileReferences<CR>', { desc = 'TS: File References', buffer = true })
            end,
          })
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
              rust = { "rustfmt" },
              nix = { "nixfmt" },
              cmake = { "cmake_format" },
            },
            format_on_save = {
              timeout_ms = 500,
              lsp_fallback = true,
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
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require('nvim-autopairs').setup {}
        '';
      }
      {
        plugin = go-nvim;
        type = "lua";
        config = ''
          require('go').setup({
            -- Disable default lsp config
            lsp_cfg = false,
            lsp_gofumpt = true,
            lsp_on_attach = false,
            lsp_keymaps = false,

            -- Formatting
            goimports = 'gopls',
            gofmt = 'gopls',
            max_line_len = 120,

            -- Tags
            tag_transform = false,
            tag_options = 'json=omitempty',

            -- Testing
            test_runner = 'go',
            verbose_tests = true,

            -- DAP debugging
            dap_debug = true,
            dap_debug_keymap = false, -- We define our own keymaps
            dap_debug_gui = true,
            dap_debug_vt = { enabled = true, enabled_commands = true, all_frames = true },

            -- Linting
            golangci_lint = {
              default = 'standard',
              severity = vim.diagnostic.severity.WARN,
            },

            -- Comments
            comment_placeholder = '   ',

            -- Icons
            icons = { breakpoint = '🔴', currentpos = '👉' },

            -- Textobjects
            textobjects = true,

            -- LuaSnip support
            luasnip = false,
          })

          -- Auto-format on save with goimports
          local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.go",
            callback = function()
              require('go.format').goimports()
            end,
            group = format_sync_grp,
          })

          -- Key mappings for Go
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "go",
            callback = function()
              -- Test commands
              vim.keymap.set('n', '<leader>gt', ':GoTest<CR>', { desc = 'Go: Test', buffer = true })
              vim.keymap.set('n', '<leader>gT', ':GoTestFunc<CR>', { desc = 'Go: Test Function', buffer = true })
              vim.keymap.set('n', '<leader>gc', ':GoCoverage<CR>', { desc = 'Go: Coverage', buffer = true })

              -- Code generation
              vim.keymap.set('n', '<leader>ga', ':GoAddTest<CR>', { desc = 'Go: Add Test', buffer = true })
              vim.keymap.set('n', '<leader>gi', ':GoImpl<CR>', { desc = 'Go: Implement Interface', buffer = true })
              vim.keymap.set('n', '<leader>gs', ':GoFillStruct<CR>', { desc = 'Go: Fill Struct', buffer = true })
              vim.keymap.set('n', '<leader>ge', ':GoIfErr<CR>', { desc = 'Go: Add if err', buffer = true })

              -- Tags
              vim.keymap.set('n', '<leader>gj', ':GoAddTag json<CR>', { desc = 'Go: Add JSON tags', buffer = true })
              vim.keymap.set('n', '<leader>gJ', ':GoRmTag json<CR>', { desc = 'Go: Remove JSON tags', buffer = true })

              -- Navigation
              vim.keymap.set('n', '<leader>gA', ':GoAlt<CR>', { desc = 'Go: Alternate file', buffer = true })

              -- Debugging
              vim.keymap.set('n', '<leader>gd', ':GoDebug<CR>', { desc = 'Go: Start Debug', buffer = true })
              vim.keymap.set('n', '<leader>gD', ':GoDebug -t<CR>', { desc = 'Go: Debug Test', buffer = true })
              vim.keymap.set('n', '<leader>gb', ':GoBreakToggle<CR>', { desc = 'Go: Toggle Breakpoint', buffer = true })

              -- Build/Run
              vim.keymap.set('n', '<leader>r', ':GoRun<CR>', { desc = 'Go: Run', buffer = true })
              vim.keymap.set('n', '<leader>B', ':GoBuild<CR>', { desc = 'Go: Build', buffer = true })

              -- Misc
              vim.keymap.set('n', '<leader>gm', ':GoModTidy<CR>', { desc = 'Go: Mod Tidy', buffer = true })
              vim.keymap.set('n', '<leader>gl', ':GoLint<CR>', { desc = 'Go: Lint', buffer = true })
            end,
          })
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
            command = '${pkgs.unstable.python3Packages.debugpy}/bin/python',
            args = { '-m', 'debugpy.adapter' },
          }
          dap.configurations.python = {
            {
              type = 'python',
              request = 'launch',
              name = 'Launch file',
              program = "''${file}",
              pythonPath = '${pkgs.unstable.python3}/bin/python',
            },
          }

          -- JavaScript/TypeScript
          dap.adapters['pwa-node'] = {
            type = 'server',
            host = 'localhost',
            port = "''${port}",
            executable = {
              command = '${pkgs.unstable.vscode-js-debug}/bin/js-debug',
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
              runtimeExecutable = '${pkgs.unstable.nodejs}/bin/node',
              runtimeArgs = { '-r', 'ts-node/register' },
            },
          }

          -- C/C++/Rust
          dap.adapters.lldb = {
            type = 'executable',
            command = '${pkgs.unstable.lldb}/bin/lldb-dap',
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
        plugin = rustaceanvim;
        type = "lua";
        config = ''
          vim.g.rustaceanvim = {
            server = {
              capabilities = require('blink.cmp').get_lsp_capabilities(),
            },
          }

          -- Key mappings for Rust
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "rust",
            callback = function()
              -- Build/Run
              vim.keymap.set('n', '<leader>r', ':split | terminal cargo run<CR>', { desc = 'Rust: Run', buffer = true })
              vim.keymap.set('n', '<leader>B', ':split | terminal cargo build<CR>', { desc = 'Rust: Build', buffer = true })
              vim.keymap.set('n', '<leader>t', ':split | terminal cargo test<CR>', { desc = 'Rust: Test', buffer = true })
              vim.keymap.set('n', '<leader>c', ':split | terminal cargo check<CR>', { desc = 'Rust: Check', buffer = true })
            end,
          })
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
