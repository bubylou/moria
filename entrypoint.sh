#!/bin/bash
set -e

if [[ "$UPDATE_ON_START" == "true" || ! -d "$APP_DIR/Moria/Binaries" ]]; then
    steamcmd +force_install_dir "$APP_DIR" +@sSteamCmdForcePlatformType windows \
        +login "$STEAM_USERNAME" "$STEAM_PASSWORD" "$STEAM_GUARD" \
        +app_update "$APP_ID" validate +quit
fi

if [[ "$RESET_SEED" == "true" ]]; then
    rm -f "$APP_DIR/Moria/Saved/Config/InviteSeed.cfg"
fi

echo "Starting fake screen"
rm -f /tmp/.X0-lock 2>&1
Xvfb :0 -screen 0 1024x768x24 -nolisten tcp &

echo "Starting Moria"
DISPLAY=:0.0 wine "$APP_DIR/Moria/Binaries/Win64/MoriaServer-Win64-Shipping.exe"
