#!/usr/bin/env bash

if [ ! -f dci.yml ]; then
    echo "You seems to be in the wrong directory"
    echo "Execute this script from the root of dci-dev-env with ./utils/update_dev_env.sh"
    exit 1
fi


function clean_repository {
    git pull origin master
    git checkout master
    git reset --hard origin/master
}


read -p "This script will reset hard all your repositories, rebuild containers, clean docker volumes. Are you sure you want to continue? (y/N)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then

    submodules="dci-control-server dci-doc dci-ui python-dciclient"
    for submodule in ${submodules}
    do
        cd $submodule
        clean_repository
        cd ..
    done

    dc="docker-compose -f dci.yml -f dci-db_init.yml -f dci-swift.yml"
    ${dc} pull
    ${dc} build
    ${dc} down -v
    ${dc} up -d

fi
