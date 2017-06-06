#!/bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ ! -f dci.yml ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

submodules="dci-control-server dci-doc dci-ui python-dciclient"
for submodule in ${submodules}
do
    [ -d $submodule ] || git clone http://github.com/redhat-cip/${submodule}
done