#!/bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ ! -f dci.yml ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

[ -d dci-control-server ] || git clone https://softwarefactory-project.io/r/dci-control-server
[ -d python-dciclient ] || git clone https://softwarefactory-project.io/r/python-dciclient
[ -d dci-ui ] || git clone https://softwarefactory-project.io/r/dci-ui
[ -d dci-doc ] || git clone --recurse-submodules https://softwarefactory-project.io/r/dci-doc