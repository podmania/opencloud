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
    version = "6.2.0";
    srcHash = "sha256-gWz6L0/lBJvhQ/6+j3g2ENPRyQYZ2jGz+i+nUZa+5zQ=";
    pkg = pkgs.opencloud.overrideAttrs (old: {
      inherit version;
      src = pkgs.fetchFromGitHub {
        owner = "opencloud-eu";
        repo = "opencloud";
        rev = "v${version}";
        hash = srcHash;
      };
    });
    imageConfig = {
      Env = [
        "IDP_ASSET_PATH=${pkg.idp-web}/assets"
        "WEB_ASSET_CORE_PATH=${pkg.web}"
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
        "foreground { ${pkg}/bin/opencloud init } ${pkg}/bin/opencloud server"
      ];
    };
  in {
    packages.${system} = {
      opencloud-image = n2c.buildImage {
        name = "opencloud";
        tag = "latest";
        fromImage = base.packages.${system}.base-image;
        maxLayers = 5;
        config = imageConfig;
      };

      opencloud-debug-image = n2c.buildImage {
        name = "opencloud";
        tag = "latest-debug";
        fromImage = base.packages.${system}.base-debug-image;
        maxLayers = 5;
        config = imageConfig;
      };

      opencloud = pkg;

      default = self.packages.${system}.opencloud-image;
    };

    opencloudVersion = version;
  };
}
