{
  description = "OpenCloud distroless image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    opencloudVersion = pkgs.opencloud.version;
    packages.${system} = {
      opencloud-image = pkgs.dockerTools.buildLayeredImage {
        name = "opencloud";
        tag = "latest";
        contents = [
          pkgs.opencloud
          pkgs.opencloud.web
          pkgs.opencloud.idp-web
          pkgs.execline
        ];
        config = {
          # https://docs.opencloud.eu/docs/dev/server/services/web/environment-variables/
          Env = [
            "IDP_ASSET_PATH=${pkgs.opencloud.idp-web}/assets"
            "WEB_ASSET_CORE_PATH=${pkgs.opencloud.web}"
            "OC_CONFIG_DIR=/etc/opencloud"
            "OC_BASE_DATA_PATH=/var/lib/opencloud"
            "PROXY_HTTP_ADDR=0.0.0.0:9200"
            "OC_URL=https://localhost:9200"
          ];

          ExposedPorts = {
            "9200/tcp" = {};
          };

          Volumes = {
            "/etc/opencloud" = {};
            "/var/lib/opencloud" = {};
          };

          # Run init once, then start the server
          Cmd = [
            "${pkgs.execline}/bin/execlineb" "-c"
            "foreground { ${pkgs.opencloud}/bin/opencloud init } ${pkgs.opencloud}/bin/opencloud server"
          ];
        };
      };
    };

    defaultPackage.${system} = self.packages.${system}.opencloud-image;
  };
}
