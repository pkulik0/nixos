{ pkgs, ... }:
let
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/6d14586a5917a1ec7f045ac97e6d00c68ea5d9f3.tar.gz");
in
{
  imports = [
    ./nvim.nix
  ];

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
}
