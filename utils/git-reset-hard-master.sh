#!/bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ ! -f README.md ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

echo -e "${RED}${0##*/} will reset your workspaces, destroy your computer and eat your children!"
read -p "Are you sure you want to continue? (y/N)" -n 1 -r
echo -e "${NOCOLOR}"

if ! [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting..."
    exit 1;
fi

set -eux

function clean_repository {
    pushd $1
    git fetch origin master
    git checkout -- .
    git checkout master
    git reset --hard origin/master
    popd
}

projects="dci-control-server dci-ui dci-doc python-dciclient python-dciauth dci-ansible"
for project in ${projects}
do
    clean_repository ${project} &
done

wait
