# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
FROM ghcr.io/linuxserver/baseimage-alpine:3.24@sha256:d07ad0eb9e65feb40ded2125e17ad8e1b33228b3cf480567378c8042ef0a8b2d AS buildstage
# renovate: datasource=github-release-attachments depName=jloutsch/kfxgen
ARG MOD_VERSION=v5.23.0
ARG PLUGIN_SHA256=662ac8343feacfa4b39dbc152a74abb8c7432e79526bf8f86a7e8438bd5dca6a
# renovate: datasource=github-releases depName=jloutsch/kfxgen
ARG SOURCE_VERSION=v5.23.0
ARG SOURCE_REV=edc2a36680945ad224a49729a0c4387f3e87ce33
RUN set -eu; version="${MOD_VERSION#v}"; \
    test "$MOD_VERSION" = "$SOURCE_VERSION"; \
    mkdir -p /root-layer/defaults/kfxgen; cd /root-layer/defaults/kfxgen; \
    curl -fsSL --retry 5 --retry-max-time 120 -o plugin.zip \
        "https://github.com/jloutsch/kfxgen/releases/download/${MOD_VERSION}/kfxgen-plugin-${version}.zip"; \
    echo "${PLUGIN_SHA256}  plugin.zip" | sha256sum -c -; \
    curl -fsSL --retry 5 --retry-max-time 120 -o source.tar.gz "https://github.com/jloutsch/kfxgen/archive/${SOURCE_REV}.tar.gz"; \
    tar -xOf source.tar.gz "kfxgen-${SOURCE_REV}/LICENSE" > LICENSE
COPY root/ /root-layer/

FROM scratch
LABEL maintainer="yshalsager"
LABEL org.opencontainers.image.source="https://github.com/linuxserver/docker-mods"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"
COPY --from=buildstage /root-layer/ /
