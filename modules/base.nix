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
  # You can import other NixOS modules here
  imports = [
    inputs.vscode-server.nixosModules.default
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
  ];

  services.vscode-server.enable = true;

  nixpkgs = {
    overlays = [overlays.unstable-packages];
    config = {allow-unfree = true;};
  };

  environment.systemPackages = with pkgs; [
    git
    git-lfs
    git-filter-repo

    zip
    wget

    bashInteractive
    nushellFull

    unstable.nil
    unstable.nixd
    alejandra
  ];

  environment.shells = with pkgs; [bashInteractive nushellFull];

  users.defaultUserShell = pkgs.bashInteractive;

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      trusted-users = ["@wheel"];
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  programs.nix-ld = {
    enable = true;
    package = inputs.nix-ld-rs.packages.x86_64-linux.nix-ld-rs;
  };

  # TODO: Set your hostname
  networking.hostName = hostcfg.hostname;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    ${usercfg.username} = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;

      # openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      # ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      # "wheel" is for sudo
      extraGroups = ["wheel"];

      shell = pkgs.nushellFull;
    };
  };
}
