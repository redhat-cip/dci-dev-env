#!/bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ ! -f README.md ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

echo What is your Software Factory username?

read softwarefactory_username

[ -d dci-control-server ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-control-server
[ -d python-dciclient ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/python-dciclient
[ -d python-dciauth ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/python-dciauth
[ -d dci-ui ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-ui
[ -d dci-doc ] || git clone --recurse-submodules ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-doc
[ -d dci-ansible ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-ansible
[ -d dci-downloader ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-downloader
[ -d dci-openstack-agent ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-openstack-agent
[ -d dci-rhel-agent ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-rhel-agent
[ -d ansible-playbook-dci-beaker ] || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/ansible-playbook-dci-beaker
