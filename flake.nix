{
  description = "A very basic flake";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # needed for vscode remote wsl fix
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

    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  # breakpoints: (_: builtins.break _)

  # function def
  outputs = {
    self, ...
  } @ inputs: let
    inherit (inputs.nixpkgs) lib;

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    systemNames = lib.systems.flakeExposed;
    forAllSystems = func: (lib.genAttrs systemNames func);

    directoriesAsList = attrSet: builtins.filter (name: attrSet.${name} == "directory") (builtins.attrNames attrSet);
    readDirsToList = path: directoriesAsList (builtins.readDir path);

    #hostNames = builtins.trace (readDirsToList ./hosts) (readDirsToList ./hosts);
    hostnames = ["macbook"];
    forAllHosts = func: (lib.genAttrs hostnames func);
  in ({
      formatter =
        forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    }
    // (let
      host = rec {
        name = "macbook";
        system = "x86_64-darwin";
        username = "dillon";
      };
      
    in {
      homeConfigurations.${host.defaultUsername} = inputs.home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {inherit inputs host;};
        pkgs = inputs.nixpkgs.legacyPackages.${host.system};
        modules = [./hosts/${host.name}/home.nix];
      };

      darwinConfigurations.${host.name} = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/${host.name}/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {inherit inputs host;};
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${host.defaultUsername} = import ./hosts/${host.name}/home.nix;
            };
          }
        ];
        specialArgs = {inherit self inputs overlays host;};
      };
    })
    // (let
      host = {
        name = "goblin-wsl";
        username = "db";
        flakeRepoPath = "/home/db/nixconf";
      };
    in {
      nixosConfigurations.${host.name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/${host.name}/configuration.nix
          inputs.NixOS-WSL.nixosModules.wsl
        ];
        specialArgs = {inherit inputs overlays host;};
      };
    }));
}
