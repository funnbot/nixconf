{
  inputs,
  lib,
  config,
  pkgs,
  host,
  ...
}: {
  imports = [
    
  ];

  home = {
    username = host.username;
    homeDirectory = lib.mkForce "/Users/${host.username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };
}
