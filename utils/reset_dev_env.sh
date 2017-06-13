#!/bin/bash

RED='\033[0;31m'
YELLOW='\e[0;33m'
NOCOLOR='\033[0m'

if [ ! -f dci.yml ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

bash ./utils/check-status.sh
if [ "$?" == "1" ];then
    echo -e "${YELLOW}${0##*/} will reset your workspaces, rebuild containers and clean docker volumes!"
    read -p "Are you sure you want to continue? (y/N)" -n 1 -r
    echo -e "${NOCOLOR}"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
    else
        echo "Aborting."
        exit 1;
    fi
fi

set -eux

function clean_repository {
    pushd $1
    git fetch origin master
    git checkout master
    git reset --hard origin/master
    popd
}

projects="dci-control-server dci-doc dci-ui python-dciclient"
for project in "${projects}"
do
    clean_repository $project &
done

dc="docker-compose -f dci.yml"
${dc} pull
${dc} build
${dc} down -v
${dc} up -d
