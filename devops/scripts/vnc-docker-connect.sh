#!/bin/bash
# shellcheck disable=SC2086
#
#
# Connect to a docker test instance's VNC session

set -e

# Bomb out if container not running
docker inspect securedrop-dev >/dev/null 2>&1 || (echo "ERROR: SD container not running."; exit 1)


# Find our securedrop docker ip
SD_DOCKER_IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' securedrop-dev)"

# Quit if the VNC port not found
nc -w5 -z "$SD_DOCKER_IP" 5901 || (echo "ERROR: VNC server not found"; exit 1)

# Are we running on gnome desktop?
if [ "$(echo \"$XDG_DATA_DIRS\" | sed 's/.*\(gnome\).*/\1/')" == "gnome" ]; then
    remote-viewer "vnc://${SD_DOCKER_IP}:5901" 2>/dev/null &

# Maybe we are running macOS
elif [ "$(uname -s)" == "Darwin" ]; then
    open "vnc://${SD_DOCKER_IP}:5901" &

else
    echo "Not sure what the VNC terminal cli arguments are for your OS."
    echo "Please add to $0 and make a pull-request"
fi