# module to build the home-manager configuration
{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # allow usage of inputs in modules from ./home
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
  home-manager.users.${config.host.username} = import ./home;
}
