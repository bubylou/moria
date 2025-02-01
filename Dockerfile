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
	GAME_PORT=7777 \
	LISTEN_PORT=7777 \
	USER=steam \
	GROUP=users \
	PUID=1000 \
	PGID=1000

# Create inital user, group, and directories
RUN mkdir -p "${APP_DIR}" "${CONFIG_DIR}" "${DATA_DIR}" \
	if [ "$USER" != "steam" ]; then \
	&& groupmod -g ${PGID} ${GROUP} \
	&& useradd -u ${PUID} -m ${USER} \
	&& chown  ${USER}:${GROUP} -R "${APP_DIR}" "${CONFIG_DIR}" "${DATA_DIR}"; \
	fi
USER ${USER}

# Copy over default min config
COPY ./MoriaServerConfig.ini ${CONFIG_DIR}/MoriaServerConfig.ini

# Update SteamCMD and game dependencies
RUN steamcmd +login anonymous +quit \
	&& xvfb-run winetricks -q vcrun2019

# Install dedicated server files
ARG RELEASE="full"
RUN if [ "$RELEASE" != "trim" ]; then \
	steamcmd +force_install_dir "$APP_DIR" +@sSteamCmdForcePlatformType windows \
	+login "$STEAM_USERNAME" "$STEAM_PASSWORD" "$STEAM_GUARD" \
	+app_update "$APP_ID" validate +quit; fi

VOLUME [ "${APP_DIR}", "${CONFIG_DIR}", "${DATA_DIR}" ]

# Check UDP connection on GAME_PORT
HEALTHCHECK --interval=30s --start-period=30s --timeout=10s \
	CMD ncat -uz 127.0.0.1 ${GAME_PORT}

EXPOSE ${GAME_PORT}/udp ${LISTEN_PORT}/tcp
ADD docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
