{
  description = "Opencloud distroless image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      opencloud-image = pkgs.dockerTools.buildLayeredImage {
        name = "opencloud";
        tag = "latest";
        contents = [ 
          pkgs.opencloud
        ];
        config = {
          ExposedPorts = {
            "9200/tcp" = {};
          };
          Volumes = {
            "/config" = {};
            "/data" = {};
          };

          Cmd = [ "${pkgs.opencloud}/bin/opencloud" ];
          # Distroless non‑root user
          User = "1000";
          WorkingDir = "/config";
        };
      };
    };

    # Expose the opencloud version for CI workflows
    opencloudVersion = pkgs.opencloud.version;

    defaultPackage.${system} = self.packages.${system}.opencloud-image;
  };
}
