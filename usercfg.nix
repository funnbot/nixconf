{lib}: {
  username = "db";

  # TODO: scan hosts directory, with cfg.nix files, to populate a similar attribute
  hosts = {
    goblin_wsl.hostcfg = {
      hostname = "goblin_wsl";
      modules = [
        ./modules/base.nix
      ];
      home-modules = [
        ./home/nushell.nix
      ];
    };
  };
}
