#!/bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ ! -f README.md ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

set -eux

docker-compose down -v --rmi local
docker-compose pull
docker-compose build
docker-compose up -d
