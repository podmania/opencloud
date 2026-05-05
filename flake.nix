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
          pkgs.execline
        ];
        config = {
          Env = [
            "ADDRESS=127.0.0.1"
            "GROUP=opencloud"
            "PORT=9200"
            "STATE_DIR=/var/lib/opencloud"
            "URL=https://localhost:9200"
            "USER=opencloud"
            "IDP_ASSET_PATH=${pkgs.opencloud}/assets" # Note: Path may vary by version
            "OC_BASE_DATA_PATH=/var/lib/opencloud"
            "OC_CONFIG_DIR=/etc/opencloud"
            "OC_INSECURE=true"
            "OC_URL=https://localhost:9200"
            "PROXY_HTTP_ADDR=127.0.0.1:9200"
            "WEB_ASSET_CORE_PATH=${pkgs.opencloud}"
          ];
          ExposedPorts = {
            "9200/tcp" = {};
          };
          Volumes = {
            "/config" = {};
            "/data" = {};
          };

          # 'foreground' runs the init command and waits for it to exit.
          # Then the shell replaces itself with 'opencloud server'.
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
