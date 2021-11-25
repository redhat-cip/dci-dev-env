#!/bin/bash

BACKUP_FILE=$1

if [ -z "${BACKUP_FILE}" ] ; then
    echo "Backup file path is required"
    echo "Usage: ${0##*/} /tmp/lastxx.dump"
    echo "Use download-latest-backup.sh"
    exit 1
fi

if ! test -x $(type -p pg_restore); then
    echo 'Please install the postgresql package to get the pg_restore command.'
    echo 'sudo dnf install postgresql'
    exit 1
fi

pg_isready -d dci -h 127.0.0.1 -p 5432 -U dci
if [ $? -ne 0 ]; then
    echo 'You database is not working.'
    echo 'command failed: pg_isready -d dci -h 127.0.0.1 -p 5432 -U dci'
    exit 1
fi

echo 'Closing all the connections to the DB'
psql --quiet -U dci -d dci -h 127.0.0.1 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='dci' AND application_name<>'psql'"
echo 'Restoring the DB'
pg_restore --clean -h 127.0.0.1 -U dci -d dci ${BACKUP_FILE}

