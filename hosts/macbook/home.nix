{
  inputs,
  lib,
  config,
  pkgs,
  host,
}: {
  imports = [];

  home = {
    username = host.defaultUsername;
    homeDirectory = "/Users/${host.defaultUsername}";
  };
}
