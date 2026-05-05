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
        Env = [
          "ADDRESS=127.0.0.1"
          "GROUP=opencloud"
          "PORT=9200"
          "STATE_DIR=/var/lib/opencloud"
          "URL=https://localhost:9200"
          "USER=opencloud"
          "IDP_ASSET_PATH=/nix/store/ji5wfk3ba7b0vaw5w1946mjkajw8j43f-opencloud-idp-web-6.1.0/assets"
          "OC_BASE_DATA_PATH=/var/lib/opencloud"
          "OC_CONFIG_DIR=/etc/opencloud"
          "OC_INSECURE=true"
          "OC_URL=https://localhost:9200"
          "PROXY_HTTP_ADDR=127.0.0.1:9200"
          "WEB_ASSET_CORE_PATH=/nix/store/sbwy5jgs8drc8501spjw5wiparg8ydhi-opencloud-web-6.2.0"
        ];
          ExposedPorts = {
            "9200/tcp" = {};
          };
          Volumes = {
            "/config" = {};
            "/data" = {};
          };

          Cmd = [ "${pkgs.opencloud}/bin/opencloud" "server" ];
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