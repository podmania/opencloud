{
  description = "OpenCloud distroless image using nix2container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix2container.url = "github:nlewo/nix2container";
    base.url = "github:podmania/base";
  };

  outputs = { self, nixpkgs, nix2container, base }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
    n2c = nix2container.outputs.packages.${system}.nix2container;
    imageConfig = {
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
      Cmd = [
        "${pkgs.execline}/bin/execlineb" "-c"
        "foreground { ${pkgs.opencloud}/bin/opencloud init } ${pkgs.opencloud}/bin/opencloud server"
      ];
    };
  in {
    packages.${system} = {
      opencloud-image = n2c.buildImage {
        name = "opencloud";
        tag = "latest";
        fromImage = base.packages.${system}.base-image;
        config = imageConfig;
      };

      opencloud-debug-image = n2c.buildImage {
        name = "opencloud";
        tag = "latest-debug";
        fromImage = base.packages.${system}.base-debug-image;
        config = imageConfig;
      };

      opencloud = pkgs.opencloud;

      default = self.packages.${system}.opencloud-image;
    };

    opencloudVersion = pkgs.opencloud.version;
  };
}
