#!/bin/bash

YELLOW='\e[0;33m'
NOCOLOR='\033[0m'


function check {
    pushd $1
    git fetch origin
    if output=$(git status --porcelain) && [[ -n "$output" ]]; then
        echo -e "${YELLOW}**$1** git repository is not clean${NOCOLOR}"
        exit 1
    fi
    popd
}

echo "health checkup"

submodules="dci-control-server dci-doc dci-ui python-dciclient"
for submodule in ${submodules}
do
    check $submodule &
done

FAIL=0
for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" != "0" ];
then
    exit 1
fi
