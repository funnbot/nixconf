# module for general configuration of a host, for use in other modules or home configs
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.host;
in {
  options.host = {
    username = mkOption {
      type = types.str;
      default = "db";
      description = "The admin username for the system.";
    };
    flakeRepoPath = mkOption {
      # only allow absolute paths
      # builtins.match matches precisely, so its like "^...$"
      type = types.strMatching "/.*";
      description = "The path to the main flake repo.";
    };
    # configOutputName = mkOption {
    #   type = types.str;
    #   default = "nixosConfiguration";
    #   description = "The name of the output in the flake.";
    # };
    # builder = mkOption {
    #   type = types.functionTo types.attr;
    # };
  };
}
