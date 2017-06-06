#!/bin/bash

if [ ! -f dci.yml ]; then
    echo "You seems to be in the wrong directory"
    echo "Execute this script from the root of dci-dev-env with ./utils/${0##*/}"
    exit 1
fi

git clone https://softwarefactory-project.io/r/dci-control-server
git clone https://softwarefactory-project.io/r/python-dciclient
git clone https://softwarefactory-project.io/r/dci-ui
git clone --recurse-submodules https://softwarefactory-project.io/r/dci-doc
