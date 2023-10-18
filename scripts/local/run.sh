#!/bin/bash

# Current script directory
SCRIPT_DIR=$(dirname $(readlink -f $0))

# Network configuration
NETWORK_NAME="name_network"

# Image names
BITWARDEN_NAME="local/name/bitwarden"
MARIADB_NAME="local/name/bitwarden/db"

# Container names
BITWARDEN_CONTAINER_NAME="bitwarden.name.local"
MARIADB_CONTAINER_NAME="db.bitwarden.name.local"

# Environment file
ENV_FILE_BITWARDEN=${SCRIPT_DIR}/../../docker/bitwarden/.env
ENV_FILE_DB=${SCRIPT_DIR}/../../docker/mariadb/.env

# Get the latest git tag for the image
TAG=$(git log -1 --pretty=%h)
BITWARDEN_LATEST="$BITWARDEN_NAME:latest"
BITWARDEN_TAGGED="$BITWARDEN_NAME:$TAG"
MARIADB_LATEST="$MARIADB_NAME:latest"
MARIADB_TAGGED="$MARIADB_NAME:$TAG"

# Stopping any old Bitwarden and MariaDB containers
docker stop "$BITWARDEN_CONTAINER_NAME" "$MARIADB_CONTAINER_NAME" 2> /dev/null;
docker rm "$BITWARDEN_CONTAINER_NAME" "$MARIADB_CONTAINER_NAME" 2> /dev/null;

# Running MariaDB container for Bitwarden
docker run -d \
  --name "$MARIADB_CONTAINER_NAME" \
  --network $NETWORK_NAME \
  --env-file ${ENV_FILE_DB} \
  "$MARIADB_TAGGED"

# Running Bitwarden container
docker run -d \
  --name "$BITWARDEN_CONTAINER_NAME" \
  -v /${SCRIPT_DIR}/../../docker/bitwarden/bitwarden/bwdata/:/etc/bitwarden \
  --network $NETWORK_NAME \
  --env-file ${ENV_FILE_BITWARDEN} \
  -p 80:8080 -p 443:443 \
  "$BITWARDEN_TAGGED"