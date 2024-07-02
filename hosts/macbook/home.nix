{
  inputs,
  lib,
  config,
  pkgs,
  host,
  ...
}: {
  imports = [];

  home = {
    username = host.defaultUsername;
    homeDirectory = lib.mkForce "/Users/${host.defaultUsername}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };
}
