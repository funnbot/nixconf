# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  overlays,
  lib,
  config,
  usercfg,
  hostcfg,
  pkgs,
  ...
}: {
  imports = hostcfg.home-modules;

  home = {
    username = usercfg.username;
    homeDirectory = "/home/${usercfg.username}";
    # sessionPath = ["/mnt/c/Users/db/Programs/vscode/bin"];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nix-output-monitor
    unstable.sage
  ];

  programs.git = {
    enable = true;
    userName = "funnbot";
    userEmail = "22226942+funnbot@users.noreply.github.com";
  };

  programs.gh = {enable = true;};
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # systemd.user.services.vscode-server.wantedBy = ["default.target"];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
