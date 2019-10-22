#!/bin/bash

echo What is your Software Factory username?

read softwarefactory_username

git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/dci-dev-env.git
cd dci-dev-env
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
