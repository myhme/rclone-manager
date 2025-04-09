#!/bin/sh

PUID=${PUID:-1001}
PGID=${PGID:-1001}

if ! getent group customgroup >/dev/null 2>&1; then
    addgroup -g "$PGID" ubuntu
fi

if ! id -u rclonemanager >/dev/null 2>&1; then
    adduser -u "$PUID" -G ubuntu -D -s /bin/sh ubuntu
fi

chown -R ubuntu:ubuntu /data

exec su-exec ubuntu "/usr/local/bin/rclone-manager"
