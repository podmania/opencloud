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
          Env = [
            # Logging
            "OC_LOG_LEVEL="          # WEB_LOG_LEVEL alias, no default
            "OC_LOG_PRETTY=false"
            "OC_LOG_COLOR=false"
            "OC_LOG_FILE="
            "WEB_LOG_LEVEL="         # Log level: panic,fatal,error,warn,info,debug,trace
            "WEB_LOG_PRETTY=false"
            "WEB_LOG_COLOR=false"
            "WEB_LOG_FILE="

            # Debug endpoints
            "WEB_DEBUG_ADDR=127.0.0.1:9104"
            "WEB_DEBUG_TOKEN="
            "WEB_DEBUG_PPROF=false"
            "WEB_DEBUG_ZPAGES=false"

            # HTTP service
            "WEB_HTTP_ADDR=127.0.0.1:9100"
            "OC_HTTP_TLS_ENABLED=false"
            "OC_HTTP_TLS_CERTIFICATE="
            "OC_HTTP_TLS_KEY="
            "WEB_HTTP_ROOT=/"

            # Caching
            "WEB_CACHE_TTL=604800"

            # CORS
            "WEB_CORS_ALLOW_ORIGINS=[https://localhost:9200]"
            "WEB_CORS_ALLOW_METHODS=[OPTIONS HEAD GET PUT PATCH POST DELETE MKCOL PROPFIND PROPPATCH MOVE COPY REPORT SEARCH]"
            "WEB_CORS_ALLOW_HEADERS=[Origin Accept Content-Type Depth Authorization Ocs-Apirequest If-None-Match If-Match Destination Overwrite X-Request-Id X-Requested-With Tus-Resumable Tus-Checksum-Algorithm Upload-Concat Upload-Length Upload-Metadata Upload-Defer-Length Upload-Expires Upload-Checksum Upload-Offset X-HTTP-Method-Override]"
            "WEB_CORS_ALLOW_CREDENTIALS=false"

            # Asset paths – use the actual Nix store paths from the opencloud package
            "WEB_ASSET_CORE_PATH=${pkgs.opencloud}/share/opencloud/web/assets/core"
            "WEB_ASSET_THEMES_PATH=${pkgs.opencloud}/share/opencloud/web/assets/themes"
            "WEB_ASSET_APPS_PATH=${pkgs.opencloud}/share/opencloud/web/assets/apps"

            # UI configuration
            "WEB_UI_CONFIG_FILE="
            "WEB_UI_THEME_SERVER=https://localhost:9200"
            "WEB_UI_THEME_PATH=/themes/opencloud/theme.json"
            "WEB_UI_CONFIG_SERVER=https://localhost:9200"

            # OIDC
            "WEB_OIDC_METADATA_URL=https://localhost:9200/.well-known/openid-configuration"
            "WEB_OIDC_AUTHORITY=https://localhost:9200"
            "WEB_OIDC_CLIENT_ID=web"
            "WEB_OIDC_RESPONSE_TYPE=code"
            "WEB_OIDC_SCOPE=openid profile email"
            "WEB_OIDC_POST_LOGOUT_REDIRECT_URI="

            # Web options
            "WEB_OPTION_DISABLE_FEEDBACK_LINK=false"
            "WEB_OPTION_RUNNING_ON_EOS=false"
            "WEB_OPTION_CONTEXTHELPERS_READ_MORE=true"
            "WEB_OPTION_LOGOUT_URL="
            "WEB_OPTION_LOGIN_URL="
            "WEB_OPTION_TOKEN_STORAGE_LOCAL=true"
            "WEB_OPTION_DISABLED_EXTENSIONS=[]"
            "WEB_OPTION_EMBED_ENABLED="
            "WEB_OPTION_EMBED_TARGET="
            "WEB_OPTION_EMBED_MESSAGES_ORIGIN="
            "WEB_OPTION_EMBED_DELEGATE_AUTHENTICATION=false"
            "WEB_OPTION_EMBED_DELEGATE_AUTHENTICATION_ORIGIN="
            "WEB_OPTION_USER_LIST_REQUIRES_FILTER=false"
            "WEB_OPTION_CONCURRENT_REQUESTS_RESOURCE_BATCH_ACTIONS=0"
            "WEB_OPTION_CONCURRENT_REQUESTS_SSE=0"
            "WEB_OPTION_CONCURRENT_REQUESTS_SHARES_CREATE=0"
            "WEB_OPTION_CONCURRENT_REQUESTS_SHARES_LIST=0"
            "WEB_OPTION_DEFAULT_APP_ID="

            # JWT secret – no default, must be set at runtime
            # "WEB_JWT_SECRET="

            # gRPC
            "WEB_GATEWAY_GRPC_ADDR=eu.opencloud.api.gateway"

            # Global OpenCloud settings – point to the declared volumes
            "OC_URL=https://localhost:9200"
            "OC_INSECURE=false"                    # Set to false for self‑signed certificates
            # "OC_JWT_SECRET="                     # No default – provide via runtime env
            "OC_BASE_DATA_PATH=/data"
            "OC_CONFIG_DIR=/config"

            "PROXY_HTTP_ADDR=0.0.0.0:9200"
            "IDP_ASSET_PATH=${pkgs.opencloud}/assets"
          ];

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
