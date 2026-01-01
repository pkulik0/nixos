{ config, pkgs, ...}:
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
    nodejs
    pnpm
    go
    python3
    clang
    clang-tools
    ninja
    cmake
    rust-bin.nightly.latest.default
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
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
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
        plugin = neo-tree-nvim;
        type = "lua";
        config = ''
          require('neo-tree').setup {}
          vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true })
        '';
      }
      {
        plugin = blink-cmp;
        type = "lua";
        config = ''
          require('blink-cmp').setup {}
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
    ];
  };
}
