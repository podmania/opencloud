{
  description = "OpenCloud distroless image";

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
          pkgs.execline
        ];
        config = {
          # currently left as default, can be manually overriden in docker-compose.yml
          # https://docs.opencloud.eu/docs/dev/server/services/web/environment-variables/
          # Env = [];

          ExposedPorts = {
            "9200/tcp" = {};
          };

          Volumes = {
            "/config" = {};
            "/data" = {};
          };

          # Run init once, then start the server
          Cmd = [
            "${pkgs.execline}/bin/execlineb" "-c"
            "foreground { ${pkgs.opencloud}/bin/opencloud init } ${pkgs.opencloud}/bin/opencloud server"
          ];

          User = "1000";
          WorkingDir = "/config";
        };
      };
    };

    defaultPackage.${system} = self.packages.${system}.opencloud-image;
  };
}
