ARG STEAMCMD_VERSION=v1.5.0-wine
FROM ghcr.io/bubylou/steamcmd:$STEAMCMD_VERSION

LABEL org.opencontainers.image.authors="Nicholas Malcolm" \
	org.opencontainers.image.source="https://github.com/bubylou/moria-docker" \
	org.opencontainers.image.licenses="MIT"

ENV APP_ID=3349480 \
	APP_NAME=moria \
	APP_DIR="/app/moria" \
	CONFIG_DIR="/config/moria" \
	DATA_DIR="/data/moria" \
	UPDATE_ON_START=false \
	RESET_SEED=false \
	STEAM_USERNAME=anonymous \
	LISTEN_PORT=7777

# Copy over default min config
COPY ./MoriaServerConfig.ini ${CONFIG_DIR}/MoriaServerConfig.ini

# Update SteamCMD and game dependencies
RUN steamcmd +login anonymous +quit \
	&& xvfb-run winetricks -q vcrun2022

# Install dedicated server files
ARG RELEASE="full"
RUN if [ "$RELEASE" != "trim" ]; then \
	steamcmd +force_install_dir "$APP_DIR" +@sSteamCmdForcePlatformType windows \
	+login "$STEAM_USERNAME" "$STEAM_PASSWORD" "$STEAM_GUARD" \
	+app_update "$APP_ID" validate +quit; fi

VOLUME [ "${APP_DIR}", "${CONFIG_DIR}", "${DATA_DIR}" ]

EXPOSE ${LISTEN_PORT}/udp
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
