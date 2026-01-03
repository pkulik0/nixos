{ pkgs, ... }:

{
  imports = [
    ./nvim.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    gnumake
    fastfetch
    gh
    claude-code
    pkg-config

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
    vcpkg
    ## Others
    go
    python3
    rust-bin.nightly.latest.default
    zigpkgs.master
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERM = "xterm-256color";
    VCPKG_ROOT = "${pkgs.vcpkg}/share/vcpkg";
  };

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

      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#qurrie";
    };
  };

  programs.git = {
    enable = true;
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3Ipi7wCDAg+CkwYoH2zkPTY/ozhMbZd58g7NCnGSnS";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "pkulik0";
        email = "me@pkulik.com";
      };
      gpg.format = "ssh";
      pull.rebase = true;
      init.defaultBranch = "dev";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      push.autoSetupRemote = true;
    };
  };

  programs.tmux = {
    enable = true;
  };
}
