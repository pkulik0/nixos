{ pkgs, ...}:

{
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    fastfetch
    nodejs
    gh
    claude-code
  ];

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
  };
}
