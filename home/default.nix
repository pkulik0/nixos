{
  pkgs,
  lib,
  mistral,
  ...
}:

let
  rust = pkgs.rust-bin.nightly.latest.default.override {
    extensions = [
      "rust-src"
      "rust-analyzer"
    ];
  };
  zig = pkgs.zigpkgs.master;
  mistral-vibe = mistral.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./nvim.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs.unstable; [
    # General
    fastfetch
    # Build tools
    gnumake
    go-task
    pkg-config
    bison
    flex
    meson
    devenv
    buf
    openssl
    pkg-config
    # CLIs
    gh
    claude-code
    gemini-cli
    mistral-vibe
    codex
    ## JS / TS
    nodejs
    pnpm
    yarn
    bun
    typescript
    ## C/C++
    gcc
    (lib.hiPrio clang)
    ninja
    cmake
    vcpkg
    mold
    llvmPackages.llvm
    ## Others
    go
    python3
    rust
    zig
    ## Infrastructure
    opentofu
    podman-compose
    ## Documentation
    mdbook
    mdbook-mermaid
    # Solana
    solana-cli
    anchor
    # Secret management
    sops
    age
  ];

  home.sessionVariables = {
    VCPKG_ROOT = "${pkgs.vcpkg}/share/vcpkg";
    CC = "clang";
    CXX = "clang++";
    OPENSSL_LIB_DIR = "${pkgs.unstable.openssl.out}/lib";
    OPENSSL_INCLUDE_DIR = "${pkgs.unstable.openssl.dev}/include";
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "alanpeabody";
    };

    shellAliases = {
      e = "exit";

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
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      anthropic_api_key = { };
    };
  };
}
