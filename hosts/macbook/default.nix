{
  hostname,
  inputs,
  ...
}: {
  imports = [
    ./configuration.nix
  ];

  host.username = "dillon";
  host.flakeRepoPath = "/crossdata/nixconf";

  # configOutputName = "darwinConfigurations";
  # builder = inputs.nix-darwin.lib.darwinSystem;
}
