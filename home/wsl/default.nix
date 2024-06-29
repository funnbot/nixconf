{inputs, ...}: {
  imports = [
    inputs.vscode-server.nixosModules.default
  ];

  services.vscode-server.enabled = true;
}
