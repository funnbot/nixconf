{hostname, inputs}: {
  host = {
    username = "dillon";
    flakeRepoPath = "/crossdata/nixconf";
  };

  configuration = import ./configuration.nix;
}