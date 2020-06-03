#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NOCOLOR='\033[0m'

if [ ! -f README.md ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

function check_uncommitted_changes {
    pushd ${1:-"."} &> /dev/null
    local=$(git rev-parse master)
    remote=$(git rev-parse origin/master)
    base=$(git merge-base master origin/master)
    project_name=${1:-"dci-dev-env"}
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        printf "║ %-18s │ ${RED}%-20s${NOCOLOR} ║\n" "${project_name}" "uncommitted changes"
    elif [ ${local} = ${remote} ]; then
        printf "║ %-18s │ ${GREEN}%-20s${NOCOLOR} ║\n" "${project_name}" "up to date"
    elif [ ${local} = ${base} ]; then
        printf "║ %-18s │ ${ORANGE}%-20s${NOCOLOR} ║\n" "${project_name}" "need to pull"
    elif [ ${remote} = ${base} ]; then
        printf "║ %-18s │ ${RED}%-20s${NOCOLOR} ║\n" "${project_name}" "need to push"
    else
        printf "║ %-18s │ ${RED}%-20s${NOCOLOR} ║\n" "${project_name}" "diverged"
    fi
    popd &> /dev/null
}


function git_remote_update {
    {
        pushd ${1:-"."}
        git remote update
        popd
    } &> /dev/null
}

projects="dci-control-server dci-ui dci-doc python-dciclient python-dciauth dci-ansible"
for project in ${projects}
do
    git_remote_update ${project} &
done
wait

printf "╔════════════════════╤══════════════════════╗\n"
check_uncommitted_changes
for project in ${projects}
do
    printf "╟────────────────────┼──────────────────────╢\n"
    check_uncommitted_changes ${project}
done
printf "╚════════════════════╧══════════════════════╝\n"
