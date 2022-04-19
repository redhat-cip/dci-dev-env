#!/bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ ! -f dci.yml ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

softwarefactory_username=$(git config --global --get gitreview.username 2>/dev/null)

if [[ -z "${softwarefactory_username}" ]]; then
    echo What is your Software Factory username?
    read softwarefactory_username
fi

cat utils/projects.lst | while read project
do
    ([ -d "$project" ] || [ -L "$project" ]) || git clone ssh://${softwarefactory_username}@softwarefactory-project.io:29418/$project
done
