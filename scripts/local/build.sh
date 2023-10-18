#!/bin/bash

# Current script directory
SCRIPT_DIR=$(dirname $(readlink -f $0))

# Network configuration
NETWORK_NAME="name_network"

# Create network if it doesn't exist
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || docker network create $NETWORK_NAME

# Image names
BITWARDEN_NAME="local/name/bitwarden"
MARIADB_NAME="local/name/bitwarden/db"

# Image tagging configuration
TAG=$(git log -1 --pretty=%h)
BITWARDEN_LATEST="$BITWARDEN_NAME:latest"
BITWARDEN_TAGGED="$BITWARDEN_NAME:$TAG"
MARIADB_LATEST="$MARIADB_NAME:latest"
MARIADB_TAGGED="$MARIADB_NAME:$TAG"

# Removing old Bitwarden and MariaDB images
docker image rm "$BITWARDEN_LATEST" "$BITWARDEN_TAGGED" 2> /dev/null
docker image rm "$MARIADB_LATEST" "$MARIADB_TAGGED" 2> /dev/null

# Build Bitwarden
docker build -t "$BITWARDEN_LATEST" -t "$BITWARDEN_TAGGED" ${SCRIPT_DIR}/../../docker/bitwarden

# Build MariaDB for Bitwarden
docker build -t "$MARIADB_LATEST" -t "$MARIADB_TAGGED" ${SCRIPT_DIR}/../../docker/mariadb
