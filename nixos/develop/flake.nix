{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
      ];
    };

    devShells.${system}.default = pkgs.mkShell {
      name = "nixos-server-dev-env";

      buildInputs = with pkgs; [
        gcc
        gnumake
        pkg-config

        python311
        python311Packages.pip
        python311Packages.virtualenv
        nodejs_22

        curl
        wget
        jq
        htop
        netcat-openbsd
        iproute2
        git
      ];

      shellHook = ''
        echo -e " Hello from devshell "
        export PIP_PREFIX="$(pwd)/.devshell/pip_packages"
        export PATH="$PIP_PREFIX/bin:$PATH"
        export PYTHONPATH="./:$PYTHONPATH"
      '';
    };
  };
}
