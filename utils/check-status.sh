#!/bin/bash

YELLOW='\e[0;33m'
NOCOLOR='\033[0m'


function health_checkup {
    pushd $1
    git fetch origin
    if output=$(git status --porcelain) && [[ -n "$output" ]]; then
        echo -e "${YELLOW}**$1** git repository is not clean${NOCOLOR}"
        exit 1
    fi
    popd
}

echo "health checkup"

projects="dci-control-server dci-ui python-dciclient"
for project in ${projects}
do
    health_checkup $project &
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
