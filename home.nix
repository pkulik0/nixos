{ pkgs, ... }:

{
  imports = [
    ./nvim.nix
  ];

  home.stateVersion = "25.11";

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
