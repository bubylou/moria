#!/usr/bin/env bash

RELEASE="trim"
STEAMCMD_VERSION="v1.5.0-wine"
container=$(buildah from ghcr.io/bubylou/steamcmd:$STEAMCMD_VERSION)

buildah config --label authors="Nicholas Malcolm" \
    --label source="https://github.com/bubylou/moria-docker" \
    --label licenses="MIT" $container

buildah config --env APP_ID=3349480 \
    --env APP_NAME="moria" \
    --env APP_DIR="/app/moria" \
    --env CONFIG_DIR="/config/moria" \
    --env DATA_DIR="/data/moria" \
    --env UPDATE_ON_START=false \
    --env RESET_SEED=false \
    --env GAME_PORT=7777 $container

# Download game dependencies
buildah run $container -- winetricks -q vcrun2022

# Install dedicated server files
if [ "$RELEASE" != "trim" ]; then
    buildah run $container -- steamcmd +force_install_dir "$APP_DIR" \
        +@sSteamCmdForcePlatformType windows \
        +login "$STEAM_USERNAME" "$STEAM_PASSWORD" "$STEAM_GUARD" \
        +app_update "$APP_ID" validate +quit
else
    buildah run $container -- steamcmd +login anonymous +quit
fi

buildah config --port $GAME_PORT/udp $container
buildah config --cmd '' $container
buildah config --entrypoint  '["./entrypoint.sh"]' $container
buildah copy $container entrypoint.sh
buildah commit $container ghcr.io/bubylou/moria:latest
