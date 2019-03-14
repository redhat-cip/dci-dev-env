#!/bin/bash

LOCAL_FILE=$1

if [ ! -z "${LOCAL_FILE}" ] && [ ! -f ${LOCAL_FILE} ]; then
    echo "$1 does not exist"
    exit 1
fi

if ! grep -q '127.0.0.1:\*:dci:dci:dci' ~/.pgpass; then
    echo 'Please do: echo "127.0.0.1:*:dci:dci:dci" >> ~/.pgpass; chmod 600 ~/.pgpass'
    exit 1
fi

if ! test -x $(type -p pg_restore); then
    echo 'Please install the postgresql package to get the pg_restore command.'
    exit 1
fi

if [ ! -z "${LOCAL_FILE}" ]; then
    echo "Using local backup file ${LOCAL_FILE}"
    BACKUP=${LOCAL_FILE}
else
    if ! test -x $(type -p swift); then
        echo 'Please install the swift client.'
        exit 1
    fi

    if ! swift stat backup|grep -q Last-Modified; then
        echo 'Please ensure swift can access the backup storage.'
        exit 1
    fi

    echo 'Downloading the last backup'
    BACKUP=/tmp/last$$.dump
    swift download -o ${BACKUP} backup $(swift list backup --long | sort -k 2,3 | tail -n 1 | sed 's!.*application/x-sql !!')
fi

echo 'Closing all the connections to the DB'
psql --quiet -U dci -d dci -h 127.0.0.1 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='dci' AND application_name<>'psql'"
echo 'Restoring the DB'
pg_restore --clean -h 127.0.0.1 -U dci -d dci ${BACKUP}
