{lib}: {
  username = "db";

  # TODO: scan hosts directory, with cfg.nix files, to populate a similar attribute
  hosts = {
    goblin-wsl.hostcfg = {
      hostname = "goblin-wsl";
      modules = [./modules/base.nix];
      home-modules = [./home/nushell.nix ./home/wsl/vscode-server.nix];
    };

    macbook-nix.hostcfg = {
      hostname = "macbook-nix";
      modules = [./modules/base.nix];
      home-modules = [./home/nushell.nix];
    };
  };
}
