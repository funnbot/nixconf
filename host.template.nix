{
  hostname,
  lib,
  inputs,
}: {
  host = {
    username = "db";
    flakeRepoPath = "/home/db/nixconf";
    configOutputName = "nixosConfiguration";
    builder = lib.nixosSystem;
  };
}
