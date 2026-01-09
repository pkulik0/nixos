{ pkgs, mistral, ... }:

let
  rust = pkgs.rust-bin.nightly.latest.default.override {
    extensions = [ "rust-src" "rust-analyzer" ];
  };
  zig = pkgs.zigpkgs.master;
  mistral-vibe = mistral.packages.${pkgs.system}.default;
in
{
  imports = [
    ./nvim.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs.unstable; [
    fastfetch

    gh
    claude-code
    gemini-cli
    mistral-vibe

    gnumake
    pkg-config
    opentofu

    mdbook
    mdbook-mermaid

    # Secret management
    sops
    age

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
    mold
    llvm
    ## Others
    go
    python3
    rust
    zig
  ];

  home.sessionVariables.VCPKG_ROOT = "${pkgs.vcpkg}/share/vcpkg";

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

      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#kulik";
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

  systemd.user.startServices = "sd-switch";
  sops = {
    age.keyFile = "/home/pk/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/home.yaml;
    secrets.anthropic_api_key = { };
  };
}
