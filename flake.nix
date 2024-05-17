{
  description = "A very basic flake";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # needed for vscode remove wsl fix
    # replacement for nix-ld, for running dynamic binaries.
    # Precompiled binaries that were not created for NixOS usually have a so-called link-loader hardcoded into them.
    # On Linux/x86_64 this is for example /lib64/ld-linux-x86-64.so.2. for glibc.
    # NixOS, on the other hand, usually has its dynamic linker in the glibc package in the Nix store and therefore cannot run these binaries.
    # Nix-ld provides a shim layer for these types of binaries.
    # It is installed in the same location where other Linux distributions install their link loader,
    # ie. /lib64/ld-linux-x86-64.so.2 and then loads the actual link loader as specified in the environment variable NIX_LD.
    # In addition, it also accepts a colon-separated path from library lookup paths in NIX_LD_LIBRARY_PATH.
    # This environment variable is rewritten to LD_LIBRARY_PATH before passing execution to the actual ld.
    # This allows you to specify additional libraries that the executable needs to run.
    nix-ld-rs = {
      url = "github:nix-community/nix-ld-rs";
      # NOTE: follows can break reproducable builds, so not always worth it
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # function def
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    NixOS-WSL,
    home-manager,
    nix-ld-rs,
  } @ inputs: let
    usercfg = import ./usercfg.nix {inherit (nixpkgs) lib;};
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    systemNames = ["x86_64-linux"];
    forAllSystems = func: (nixpkgs.lib.genAttrs systemNames func);
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = let
      hostname = "goblin_wsl";
    in {
      ${hostname} = nixpkgs.lib.nixosSystem {
        # allow usage of inputs in modules
        specialArgs = {
          inherit inputs usercfg overlays;
          inherit (usercfg.hosts.${hostname}) hostcfg;
        };

        modules = [
          ./hosts/${hostname}
          NixOS-WSL.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # allow usage of inputs in modules from ./home
            home-manager.extraSpecialArgs = {
              inherit inputs usercfg;
              inherit (usercfg.hosts.${hostname}) hostcfg;
            };
            home-manager.users.${usercfg.username} = import ./home/base.nix;
          }
        ];
      };
    };
  };
}
