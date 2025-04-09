#!/bin/sh
echo "Entrypoint script running as user: $(whoami) (UID: $(id -u))"
echo "Executing rclone-manager..."
# Execute the main application directly.
# The container's USER instruction ensures this runs as the correct user.
exec "/usr/local/bin/rclone-manager"
