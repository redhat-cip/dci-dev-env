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
[ -d python-dciauth ] || git clone https://softwarefactory-project.io/r/python-dciauth
[ -d dci-ui ] || git clone https://softwarefactory-project.io/r/dci-ui
[ -d dci-doc ] || git clone --recurse-submodules https://softwarefactory-project.io/r/dci-doc
[ -d dci-ansible ] || git clone https://softwarefactory-project.io/r/dci-ansible
[ -d dci-downloader ] || git clone https://softwarefactory-project.io/r/dci-downloader
[ -d dci-openstack-agent ] || git clone https://softwarefactory-project.io/r/dci-openstack-agent
[ -d dci-rhel-agent ] || git clone https://softwarefactory-project.io/r/dci-rhel-agent
[ -d ansible-playbook-dci-beaker ] || git clone https://softwarefactory-project.io/r/ansible-playbook-dci-beaker
