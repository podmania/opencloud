FROM nixos/nix:latest AS builder
RUN printf "extra-experimental-features = nix-command flakes\n" >> /etc/nix/nix.conf

ARG REPO=podmania/opencloud
RUN nix build "github:${REPO}#opencloud" --impure --out-link /build/opencloud
RUN nix build nixpkgs#execline --impure --out-link /build/execline
RUN mkdir -p /rootfs/nix/store && \
    for path in $(nix-store -qR /build/opencloud) $(nix-store -qR /build/execline); do \
      cp -a "$path" "/rootfs$path" 2>/dev/null || true; \
    done && \
    cp -aL /build/opencloud "/rootfs/nix/store/app"
RUN EXECLINE=$(readlink -f /build/execline/bin/execlineb) && \
    printf '#!%s -c\nforeground { /nix/store/app/bin/opencloud init } /nix/store/app/bin/opencloud server\n' "$EXECLINE" > /rootfs/nix/store/app/bin/start && \
    chmod +x /rootfs/nix/store/app/bin/start

FROM ghcr.io/podmania/base:latest
COPY --from=builder /rootfs /
ENV IDP_ASSET_PATH=/nix/store/app/assets
ENV WEB_ASSET_CORE_PATH=/nix/store/app/web
ENV OC_CONFIG_DIR=/etc/opencloud
ENV OC_BASE_DATA_PATH=/var/lib/opencloud
ENV PROXY_HTTP_ADDR=0.0.0.0:9200
ENV OC_URL=https://localhost:9200
ENTRYPOINT ["/nix/store/app/bin/start"]
