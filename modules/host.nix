{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.host;
in {
  options.host = {
    name = mkOption {
      type = types.str;
      default = "nix";
      description = "The hostname of the system.";
    };
  };
}
