#!/bin/bash -e

if [ ! -f dci.yml ]; then
    echo "You seems to be in the wrong directory"
    echo "Execute this script from the root of dci-dev-env with ./utils/boostrap.sh"
    exit 1
fi

git clone http://softwarefactory-project.io/r/dci-control-server
git clone http://softwarefactory-project.io/r/python-dciclient
git clone http://softwarefactory-project.io/r/dci-ui
git clone http://softwarefactory-project.io/r/p/dci-agent.git
git clone --recurse-submodules http://softwarefactory-project.io/r/dci-doc
