FROM ghcr.io/bubylou/steamcmd:wine

LABEL org.opencontainers.image.authors="Nicholas Malcolm"
LABEL org.opencontainers.image.source="https://github.com/bubylou/moria-docker"

ENV APP_ID=3349480 \
	APP_NAME=moria \
	APP_DIR="/app/moria" \
	CONFIG_DIR="/config/moria" \
	DATA_DIR="/data/moria"

RUN mkdir -p "$APP_DIR" "$CONFIG_DIR" "$DATA_DIR" \
	&& steamcmd +login anonymous +quit \
	&& xvfb-run winetricks -q vcrun2019

VOLUME [ "$APP_DIR", "$CONFIG_DIR", "$DATA_DIR" ]

ENV UPDATE_ON_START=false \
	STEAM_USERNAME=anonymous \
	STEAM_PASSWORD="" \
	STEAM_GUARD_CODE="" \
	GAME_PORT=7777 \
	LISTEN_PORT=7777

EXPOSE $GAME_PORT/udp $LISTEN_PORT/tcp
ADD docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
