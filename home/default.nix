# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  overlays,
  lib,
  config,
  usercfg,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./nushell.nix
  ];
  _ = builtins.trace usercfg "asd";
  home = {
    username = "db";
    homeDirectory = "/home/db";
    sessionPath = [
      "/mnt/c/Users/db/Programs/vscode/bin"
    ];
  };

  programs.nushell.shellAliases = {
    quick-rebuild = "sudo rm ~/nixconf/flake.lock and sudo nixos-rebuild switch --flake ~/nixconf/.#goblin_wsl";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nixd
    nil
    nix-output-monitor
    unstable.sage
  ];

  programs.git = {
    enable = true;
    userName = "funnbot";
    userEmail = "22226942+funnbot@users.noreply.github.com";
  };

  programs.gh = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
