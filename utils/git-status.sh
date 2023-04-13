#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
NOCOLOR='\033[0m'

if [ ! -f dci.yml ]; then
    echo -e "${RED}You seems to be in the wrong directory"
    echo -e "Execute this script from the root of dci-dev-env with ./utils/${0##*/}${NOCOLOR}"
    exit 1
fi

function check_uncommitted_changes {
    project_name=${1:-"dci-dev-env"}
    if [ ! -d ${1:-"."} ]; then
        printf "║ %-25s │ ${PURPLE}%-20s${NOCOLOR} ║\n" "${project_name}" "does not exist"
        return
    fi
    pushd ${1:-"."} &> /dev/null
    local=$(git rev-parse master)
    remote=$(git rev-parse origin/master)
    base=$(git merge-base master origin/master)
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        printf "║ %-25s │ ${RED}%-20s${NOCOLOR} ║\n" "${project_name}" "uncommitted changes"
    elif [ ${local} = ${remote} ]; then
        printf "║ %-25s │ ${GREEN}%-20s${NOCOLOR} ║\n" "${project_name}" "up to date"
    elif [ ${local} = ${base} ]; then
        printf "║ %-25s │ ${ORANGE}%-20s${NOCOLOR} ║\n" "${project_name}" "need to pull"
    elif [ ${remote} = ${base} ]; then
        printf "║ %-25s │ ${RED}%-20s${NOCOLOR} ║\n" "${project_name}" "need to push"
    else
        printf "║ %-25s │ ${RED}%-20s${NOCOLOR} ║\n" "${project_name}" "diverged"
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

cat utils/projects.lst | while read project
do
    git_remote_update "${project}" &
done
wait

printf "╔═══════════════════════════╤══════════════════════╗\n"
check_uncommitted_changes
cat utils/projects.lst | while read project
do
    printf "╟───────────────────────────┼──────────────────────╢\n"
    check_uncommitted_changes ${project}
done
printf "╚═══════════════════════════╧══════════════════════╝\n"
