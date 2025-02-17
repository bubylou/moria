VERSION 0.8
FROM ghcr.io/bubylou/steamcmd:v1.5.1-wine
LABEL org.opencontainers.image.source="https://github.com/bubylou/moria"
LABEL org.opencontainers.image.authors="Nicholas Malcolm <bubylou@pm.me>"
LABEL org.opencontainers.image.licenses="MIT"
ARG --global name=bubylou/moria
ARG --global --required tag

build:
    ENV APP_ID=3349480
    ENV APP_NAME=moria
    ENV APP_DIR="/app/moria"
    ENV UPDATE_ON_START=true
    ENV RESET_SEED=false
    ENV STEAM_USERNAME=anonymous
    ENV LISTEN_PORT=7777

    COPY ./MoriaServerConfig.ini "$CONFIG_DIR/MoriaServerConfig.ini"
    RUN mkdir -p "$APP_DIR" \
        && steamcmd +login anonymous +quit \
        && xvfb-run winetricks -q vcrun2022

    VOLUME [ "$APP_DIR" ]

    COPY entrypoint.sh /entrypoint.sh
    ENTRYPOINT ["/entrypoint.sh"]

    SAVE IMAGE --cache-from=docker.io/$name:main --push \
        docker.io/$name:$tag docker.io/$name:latest
    SAVE IMAGE --cache-from=ghcr.io/$name:main --push \
        ghcr.io/$name:$tag ghcr.io/$name:latest

full:
    FROM +build
    RUN steamcmd +force_install_dir "$APP_DIR" \
        +@sSteamCmdForcePlatformType windows \
        +login "$STEAM_USERNAME" "$STEAM_PASSWORD" "$STEAM_GUARD" \
        +app_update "$APP_ID" validate +quit

    SAVE IMAGE --cache-from=docker.io/$name:main-full --push \
        docker.io/$name:$tag-full docker.io/$name:latest-full
    SAVE IMAGE --cache-from=ghcr.io/$name:main-full --push \
        ghcr.io/$name:$tag-full ghcr.io/$name:latest-full

all:
    BUILD +build
    BUILD +full
