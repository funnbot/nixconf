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
  imports =
    [
      inputs.vscode-server.nixosModules.home
    ]
    ++ hostcfg.home-modules;

  services.vscode-server.enable = true;

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

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "funnbot";
    userEmail = "22226942+funnbot@users.noreply.github.com";
  };

  programs.gh = {enable = true;};
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      quick-rebuild = "sudo nixos-rebuild switch --flake ~/nixconf/.#${hostcfg.hostname}";
      nix-rebuild-debug = "sudo nix build '.#nixosConfigurations.${hostcfg.hostname}.config.system.build.toplevel' --debugger --impure --ignore-try --no-warn-dirty";
    };
  };

  # systemd.user.services.vscode-server.wantedBy = ["default.target"];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
