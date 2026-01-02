{ pkgs, ... }:

{
  imports = [
    ./nvim.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    jujutsu
    fastfetch
    gh
    claude-code

    # Programming languages & tools
    ## JS / TS
    nodejs
    pnpm
    bun
    typescript
    ## C/C++
    clang
    ninja
    cmake
    ## Others
    go
    python3
    rust-bin.nightly.latest.default
    zigpkgs.master
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
        "podman"
        "kubectl"
      ];
    };

    shellAliases = {
      e = "exit";
      c = "clear";

      gp = "git push";
      gpf = "git push -f";

      rebuild = "sudo nixos-rebuild switch --flake .#qurrie";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "pkulik0";
        email = "me@pkulik.com";
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3Ipi7wCDAg+CkwYoH2zkPTY/ozhMbZd58g7NCnGSnS";
      };
      gpg = {
        format = "ssh";
      };
      pull = {
        rebase = true;
      };
      init = {
        defaultBranch = "dev";
      };
      url."ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
      commit = {
        gpgsign = true;
      };
      push = {
        autoSetupRemote = true;
      };
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = ''
      # Easier prefix
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # Split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Easy config reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Vim-like pane switching
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Enable true colors
      set -ga terminal-overrides ",*256col*:Tc"

      # Status bar styling
      set -g status-style bg=default,fg=white
      set -g status-left-length 30
      set -g status-left "#[fg=green][#S] "
      set -g status-right "#[fg=yellow]%Y-%m-%d #[fg=white]%H:%M"

      # Pane border colors
      set -g pane-border-style fg=colour240
      set -g pane-active-border-style fg=colour33

      # Window status
      setw -g window-status-current-style fg=colour81,bg=colour238,bold
      setw -g window-status-style fg=colour138,bg=colour235,none
    '';
  };
}
