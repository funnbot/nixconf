{hostcfg, ...}: {
  programs = {
    nushell = {
      enable = true;
      # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
      configFile.source = ./config.nu;
      shellAliases = {
        vi = "hx";
        vim = "hx";
        nano = "hx";
        quick-rebuild = "sudo nixos-rebuild switch --flake ~/nixconf/.#${hostcfg.hostname}";
      };
    };
    carapace.enable = true;
    carapace.enableNushellIntegration = true;
    helix.enable = true;
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };
}
